const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { createClient } = require("@supabase/supabase-js");
const crypto = require("crypto");

dotenv.config();

const app = express();

// ==================================================
// SERVER CONFIGURATION
// ==================================================

const PORT = process.env.PORT || 3000;

const OPENAI_API_KEY =
  process.env.OPENAI_API_KEY;

const OPENAI_MODEL =
  process.env.OPENAI_MODEL ||
  "gpt-4.1-mini";

const OPENAI_IMAGE_MODEL =
  process.env.OPENAI_IMAGE_MODEL ||
  "gpt-image-2";

const TICKETMASTER_API_KEY =
  process.env.TICKETMASTER_API_KEY;

// ==================================================
// SUPABASE CONFIGURATION
// ==================================================

const SUPABASE_URL =
  process.env.SUPABASE_URL;

const SUPABASE_SERVICE_ROLE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY;

let supabaseAdmin = null;

if (
  SUPABASE_URL &&
  SUPABASE_SERVICE_ROLE_KEY
) {
  supabaseAdmin = createClient(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );

  console.log(
    "Supabase admin client configured."
  );
} else {
  console.warn(
    "Supabase admin client is NOT configured. " +
    "Account deletion will be unavailable."
  );
}

// --------------------------------------------------
// MIDDLEWARE
// --------------------------------------------------

app.use(cors());

app.use(
  express.json({
    limit: "20mb",
  })
);
// ==================================================
// ACCOUNT DELETION
// DELETE /api/account/delete
// ==================================================

app.post(
  "/api/account/delete",
  async (req, res) => {
    try {
      // ------------------------------------------------
      // SUPABASE CONFIGURATION CHECK
      // ------------------------------------------------

      if (!supabaseAdmin) {
        return res.status(500).json({
          success: false,
          error:
            "Account deletion is not configured on the server.",
        });
      }

      // ------------------------------------------------
      // READ AUTHORIZATION HEADER
      // ------------------------------------------------

      const authorization =
        req.headers.authorization || "";

      if (
        !authorization.startsWith(
          "Bearer "
        )
      ) {
        return res.status(401).json({
          success: false,
          error:
            "Authentication is required.",
        });
      }

      const accessToken =
        authorization
          .substring(7)
          .trim();

      if (!accessToken) {
        return res.status(401).json({
          success: false,
          error:
            "Authentication token is missing.",
        });
      }

      // ------------------------------------------------
      // VERIFY TOKEN WITH SUPABASE
      // ------------------------------------------------

      const {
        data: { user },
        error: userError,
      } =
        await supabaseAdmin.auth.getUser(
          accessToken
        );

      if (userError || !user) {
        console.error(
          "Account deletion authentication error:",
          userError
        );

        return res.status(401).json({
          success: false,
          error:
            "Your session is invalid or has expired.",
        });
      }

      // IMPORTANT:
      // Never trust a user ID supplied by Flutter.
      // Always use the verified Supabase user ID.

      const userId = user.id;

      console.log(
        `Account deletion requested for user: ${userId}`
      );

      // ------------------------------------------------
      // DELETE PROFILE IMAGE FILES
      // ------------------------------------------------

      try {
        const profileImagePaths = [
          `${userId}/profile_image.jpg`,
          `${userId}/profile.jpg`,
        ];

        const {
          error: storageError,
        } =
          await supabaseAdmin.storage
            .from("profile_images")
            .remove(
              profileImagePaths
            );

        if (storageError) {
          console.warn(
            "Profile image deletion warning:",
            storageError
          );
        }
      } catch (storageError) {
        console.warn(
          "Profile image deletion warning:",
          storageError
        );
      }

      // ------------------------------------------------
      // DELETE USER DATA
      // ------------------------------------------------

      const tables = [
        "wardrobe_items",
        "events",
        "profiles",
      ];

      for (const table of tables) {
        const {
          error,
        } =
          await supabaseAdmin
            .from(table)
            .delete()
            .eq(
              "user_id",
              userId
            );

        if (error) {
          // Some profiles tables may use `id`
          // instead of `user_id`.

          if (
            table === "profiles"
          ) {
            const {
              error: profileError,
            } =
              await supabaseAdmin
                .from(table)
                .delete()
                .eq(
                  "id",
                  userId
                );

            if (profileError) {
              throw new Error(
                `Failed to delete ${table}: ${profileError.message}`
              );
            }
          } else {
            throw new Error(
              `Failed to delete ${table}: ${error.message}`
            );
          }
        }
      }

      // ------------------------------------------------
      // DELETE SUPABASE AUTH ACCOUNT
      // ------------------------------------------------

      const {
        error: deleteAuthError,
      } =
        await supabaseAdmin.auth.admin
          .deleteUser(userId);

      if (deleteAuthError) {
        throw new Error(
          `Failed to delete authentication account: ${deleteAuthError.message}`
        );
      }

      console.log(
        `Account successfully deleted: ${userId}`
      );

      return res.json({
        success: true,
        message:
          "Your Vestra account has been permanently deleted.",
      });
    } catch (error) {
      console.error(
        "Account deletion error:",
        error
      );

      return res.status(500).json({
        success: false,
        error:
          error?.message ||
          "Vestra could not delete your account.",
      });
    }
  }
);
// --------------------------------------------------
// HEALTH CHECK
// --------------------------------------------------

app.get("/", (req, res) => {
  res.json({
    success: true,
    service: "Vestra Backend",
    status: "online",
    version: "1.0.0",
    ai: {
      model: OPENAI_MODEL,
      configured: Boolean(OPENAI_API_KEY),
    },
  });
});

// ==================================================
// SHARED AI HELPER
// ==================================================

async function callOpenAI({
  systemPrompt,
  userPrompt,
  temperature = 0.7,
}) {
  if (!OPENAI_API_KEY) {
    throw new Error(
      "OPENAI_API_KEY is not configured on the server."
    );
  }

  const response = await fetch(
    "https://api.openai.com/v1/chat/completions",
    {
      method: "POST",

      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },

      body: JSON.stringify({
        model: OPENAI_MODEL,

        messages: [
          {
            role: "system",
            content: systemPrompt,
          },
          {
            role: "user",
            content: userPrompt,
          },
        ],

        temperature,

        response_format: {
          type: "json_object",
        },
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();

    console.error(
      "OpenAI API error:",
      errorText
    );

    const error = new Error(
      "AI service request failed."
    );

    error.status = response.status;
    error.details = errorText;

    throw error;
  }

  const data = await response.json();

  const content =
    data?.choices?.[0]?.message?.content;

  if (!content) {
    throw new Error(
      "The AI returned an empty response."
    );
  }

  try {
    return JSON.parse(content);
  } catch (error) {
    console.error(
      "AI returned invalid JSON:",
      content
    );

    throw new Error(
      "The AI returned invalid JSON."
    );
  }
}

// ==================================================
// AI STYLIST
// COMPATIBILITY-AWARE STYLING ENGINE
// ==================================================

// ==================================================
// VESTRA STYLE INTELLIGENCE HELPERS
// ==================================================

function normalizeIntentText(value) {
  return String(value ?? "")
    .replace(/\s+/g, " ")
    .trim();
}

function containsAny(text, patterns) {
  return patterns.some((pattern) => pattern.test(text));
}

function extractNaturalCurrentRequest(value) {
  const text = normalizeIntentText(value);

  // AIStylistScreen may append saved profile information to the natural
  // language request. Strip those generated profile labels before deciding
  // what the user wants RIGHT NOW. The same data is still supplied separately
  // through stylePreferences and aesthetic.
  return text
    .split(/\bPreferred styles\s*:/i)[0]
    .split(/\bPreferred fits\s*:/i)[0]
    .split(/\bPreferred colors\s*:/i)[0]
    .split(/\bPersonal aesthetic\s*:/i)[0]
    .trim();
}

function buildStyleIntent({
  occasion,
  request,
  stylePreferences,
  aesthetic,
}) {
  const currentRequest = extractNaturalCurrentRequest(request);
  const occasionText = normalizeIntentText(occasion);
  const aestheticText = normalizeIntentText(aesthetic);
  const savedText = normalizeIntentText(
    JSON.stringify(stylePreferences || {})
  );

  const currentText = `${currentRequest} ${occasionText}`.toLowerCase();

  const intentSignals = [];
  const strongCurrentPreferences = [];
  const explicitAvoidances = [];
  const preferredGarmentTypes = [];
  const contextualFootwearDirection = [];
  const addUnique = (list, value) => {
    if (!list.includes(value)) list.push(value);
  };

  if (containsAny(currentText, [
    /\bfeminine\b/i,
    /\bfeminine[- ]?looking\b/i,
    /\bladylike\b/i,
    /\bromantic\b/i,
  ])) {
    addUnique(intentSignals, "feminine styling direction");
    addUnique(strongCurrentPreferences, "feminine");
  }

  if (containsAny(currentText, [
    /\bmasculine\b/i,
    /\bmasculine[- ]?looking\b/i,
    /\bmenswear\b/i,
    /\bmanly\b/i,
  ])) {
    addUnique(intentSignals, "masculine styling direction");
    addUnique(strongCurrentPreferences, "masculine");
  }

  if (containsAny(currentText, [
    /\bluxurious?\b/i,
    /\bluxury\b/i,
    /\bluxe\b/i,
    /\bhigh[- ]end\b/i,
    /\bexpensive\b/i,
    /\brich[- ]looking\b/i,
  ])) {
    addUnique(intentSignals, "luxury / elevated styling");
    addUnique(strongCurrentPreferences, "luxurious");
  }

  if (containsAny(currentText, [
    /\bclassy\b/i,
    /\belegant\b/i,
    /\bsophisticated\b/i,
    /\brefined\b/i,
    /\bpolished\b/i,
  ])) {
    addUnique(intentSignals, "classy / refined styling");
    addUnique(strongCurrentPreferences, "classy");
  }

  if (containsAny(currentText, [
    /\bstatement\b/i,
    /\bcommanding\b/i,
    /\bhead[- ]turning\b/i,
    /\bdramatic\b/i,
    /\bbold\b/i,
    /\bshow[- ]stopping\b/i,
  ])) {
    addUnique(intentSignals, "statement / high-impact styling");
    addUnique(strongCurrentPreferences, "statement");
  }

  if (containsAny(currentText, [
    /\bminimal\b/i,
    /\bminimalist\b/i,
    /\bunderstated\b/i,
    /\bquiet luxury\b/i,
  ])) {
    addUnique(intentSignals, "minimal / controlled styling");
    addUnique(strongCurrentPreferences, "minimal");
  }

  if (containsAny(currentText, [
    /\beditorial\b/i,
    /\bavant[- ]garde\b/i,
    /\bfashion[- ]forward\b/i,
    /\bexperimental\b/i,
    /\bconceptual\b/i,
  ])) {
    addUnique(intentSignals, "editorial / fashion-forward styling");
    addUnique(strongCurrentPreferences, "editorial");
  }

  if (containsAny(currentText, [
    /\bcasual\b/i,
    /\brelaxed\b/i,
    /\beveryday\b/i,
    /\bcomfortable\b/i,
  ])) {
    addUnique(intentSignals, "casual / wearable styling");
  }

  if (containsAny(currentText, [
    /\bdate\b/i,
    /\bdate[- ]night\b/i,
    /\bdinner date\b/i,
  ])) {
    addUnique(intentSignals, "intentional date-night styling");
  }

  if (containsAny(currentText, [
    /\bblack tie\b/i,
    /\bblack-tie\b/i,
    /\bgala\b/i,
    /\bred carpet\b/i,
  ])) {
    addUnique(intentSignals, "formal evening styling");
  }

  if (containsAny(currentText, [
    /\bdress\b/i,
    /\bgown\b/i,
    /\bmaxi dress\b/i,
    /\bmini dress\b/i,
    /\bmidi dress\b/i,
  ])) {
    addUnique(preferredGarmentTypes, "dress / one-piece garment");
  }

  if (containsAny(currentText, [
    /\bsuit\b/i,
    /\btailoring\b/i,
    /\bblazer\b/i,
    /\btrouser\b/i,
    /\btrousers\b/i,
  ])) {
    addUnique(preferredGarmentTypes, "tailoring / trousers");
  }

  if (containsAny(currentText, [
    /\bformal shoes?\b/i,
    /\bdress shoes?\b/i,
    /\bpolished shoes?\b/i,
    /\bheels?\b/i,
    /\bpumps?\b/i,
    /\bstilettos?\b/i,
  ])) {
    addUnique(contextualFootwearDirection, "formal / polished footwear");
  }

  if (containsAny(currentText, [
    /\bsneakers?\b/i,
    /\btrainers?\b/i,
    /\bsneaker[- ]luxe\b/i,
  ])) {
    addUnique(contextualFootwearDirection, "sneakers only when contextually supported");
  }

  // Explicit avoidance is stronger than an absent preference.
  const avoidancePattern = /(?:don't|do not|dont|avoid|without|no)\s+(?:wear\s+|use\s+|include\s+)?([^.!?;]+)/gi;
  let avoidanceMatch;
  while ((avoidanceMatch = avoidancePattern.exec(currentRequest)) !== null) {
    const phrase = avoidanceMatch[1]?.trim();
    if (phrase && phrase.length <= 100) {
      addUnique(explicitAvoidances, phrase);
    }
  }

  // "Preferably a dress" is a strong current preference, not an absolute ban
  // on trousers or other alternatives.
  if (containsAny(currentText, [
    /\bpreferably\s+(?:a\s+)?dress\b/i,
    /\bi(?:'d| would) prefer\s+(?:a\s+)?dress\b/i,
    /\bprefer\s+(?:a\s+)?dress\b/i,
  ])) {
    addUnique(strongCurrentPreferences, "dress strongly preferred for this request");
  }

  const savedPreferenceSignals = [];
  const pushSaved = (label, regex) => {
    if (regex.test(savedText)) addUnique(savedPreferenceSignals, label);
  };

  pushSaved("saved color tendencies", /colors|preferredColors|selectedColors/i);
  pushSaved("saved style tendencies", /styles|preferredStyles|selectedStyles/i);
  pushSaved("saved fit tendencies", /fits|preferredFits|selectedFits/i);
  pushSaved("saved aesthetic tendencies", /aesthetic|aesthetics/i);

  if (aestheticText) {
    addUnique(savedPreferenceSignals, `saved personal aesthetic: ${aestheticText}`);
  }

  return {
    currentRequest: currentRequest || "Not specified",
    intentSignals,
    strongCurrentPreferences,
    explicitAvoidances,
    preferredGarmentTypes,
    contextualFootwearDirection,
    savedPreferenceSignals,
    rule: "Current request > explicit current restriction/requirement > occasion > garment compatibility > saved preferences > experimentation.",
  };
}

function buildLookBriefs(styleIntent) {
  const strong = styleIntent?.strongCurrentPreferences || [];
  const garments = styleIntent?.preferredGarmentTypes || [];

  const feminine = strong.includes("feminine");
  const masculine = strong.includes("masculine");
  const luxury = strong.includes("luxurious");
  const classy = strong.includes("classy");
  const dressPreferred =
    strong.includes("dress strongly preferred for this request") ||
    garments.includes("dress / one-piece garment");

  const baseDirection = [
    feminine ? "Preserve a clearly feminine fashion direction." : "",
    masculine ? "Preserve a clearly masculine fashion direction." : "",
    luxury ? "Maintain an elevated luxury character." : "",
    classy ? "Maintain polish, refinement and intentionality." : "",
    dressPreferred
      ? "A compatible dress or one-piece should receive strong priority when available."
      : "",
  ]
    .filter(Boolean)
    .join(" ");

  return [
    {
      lookRole: "REFINED",
      objective:
        "Give the most direct, polished and believable interpretation of the user's request. Keep the composition controlled and sophisticated.",
      drama: "low-to-medium",
      variationAxes: [
        "silhouette control",
        "clean styling",
        "restrained accessories",
      ],
      instruction: `${baseDirection} Favor the strongest straightforward wardrobe combination. Avoid unnecessary experimentation.`,
    },
    {
      lookRole: "STATEMENT",
      objective:
        "Create the commanding, memorable and high-impact interpretation of the same request without losing occasion suitability.",
      drama: "high",
      variationAxes: [
        "visual drama",
        "statement proportion",
        "strong focal accessory or footwear",
        "bolder contrast",
      ],
      instruction: `${baseDirection} Increase visual impact through proportion, silhouette, texture, layering, color contrast or a statement accessory. Do not change the requested styling direction merely to be different.`,
    },
    {
      lookRole: "ALTERNATIVE",
      objective:
        "Create a genuinely different editorial or after-dark interpretation that still satisfies the same request and occasion.",
      drama: "medium-to-high",
      variationAxes: [
        "alternative silhouette",
        "different layering architecture",
        "different accessory direction",
        "different color relationship",
      ],
      instruction: `${baseDirection} Explore a different styling architecture rather than making a slightly altered copy of Look 1. If the same anchor garment remains strongest, keep it and change how it is framed.`,
    },
  ];
}

function buildLookBriefText(briefs) {
  return briefs
    .map(
      (brief, index) => `
LOOK ${index + 1} — ${brief.lookRole}
Objective: ${brief.objective}
Drama: ${brief.drama}
Required variation axes: ${brief.variationAxes.join(", ")}
Direction: ${brief.instruction}
`
    )
    .join("\n");
}

function normalizedWords(value) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, " ")
    .split(/\s+/)
    .filter((word) => word.length > 2);
}

function jaccardSimilarity(a, b) {
  const setA = new Set(normalizedWords(a));
  const setB = new Set(normalizedWords(b));

  if (setA.size === 0 && setB.size === 0) return 1;

  let intersection = 0;
  for (const word of setA) {
    if (setB.has(word)) intersection += 1;
  }

  const union = new Set([...setA, ...setB]).size;
  return union === 0 ? 1 : intersection / union;
}

function validateLookDiversity(looks) {
  if (!Array.isArray(looks) || looks.length !== 3) {
    return {
      valid: false,
      reason: "Exactly three looks are required.",
    };
  }

  const expectedRoles = [
    "REFINED",
    "STATEMENT",
    "ALTERNATIVE",
  ];

  const roles = looks.map((look) =>
    String(look?.lookRole || "")
      .trim()
      .toUpperCase()
  );

  if (roles.some((role, index) => role !== expectedRoles[index])) {
    return {
      valid: false,
      reason:
        "The three looks must use the REFINED, STATEMENT and ALTERNATIVE creative roles in order.",
    };
  }

  const variationSets = looks.map((look) =>
    Array.isArray(look?.variationAxes)
      ? look.variationAxes
          .map((axis) => String(axis).trim().toLowerCase())
          .filter(Boolean)
      : []
  );

  if (variationSets.some((axes) => axes.length < 2)) {
    return {
      valid: false,
      reason:
        "Each look must identify at least two meaningful variation axes.",
    };
  }

  const directions = looks.map(
    (look) =>
      `${look?.stylingDirection || ""} ${look?.outfitName || ""}`
  );

  const pairSimilarities = [];
  for (let i = 0; i < directions.length; i += 1) {
    for (let j = i + 1; j < directions.length; j += 1) {
      pairSimilarities.push(
        jaccardSimilarity(directions[i], directions[j])
      );
    }
  }

  const allDirectionsNearlySame = pairSimilarities.every(
    (score) => score >= 0.78
  );

  if (allDirectionsNearlySame) {
    return {
      valid: false,
      reason:
        "The styling directions are too similar across the three looks.",
    };
  }

  const fingerprints = looks.map((look) => {
    const ids = Array.isArray(look?.selectedItemIds)
      ? look.selectedItemIds
          .map(String)
          .sort()
          .join(",")
      : "";

    const suggested = Array.isArray(look?.suggestedPieces)
      ? look.suggestedPieces
          .map(
            (piece) =>
              `${piece?.category || ""}:${piece?.name || ""}`
          )
          .join("|")
      : "";

    return `${ids}::${suggested}`.toLowerCase();
  });

  if (new Set(fingerprints).size === 1) {
    return {
      valid: false,
      reason:
        "The three looks use the same wardrobe architecture and need stronger variation.",
    };
  }

  return {
    valid: true,
    reason:
      "The three looks have distinct creative roles and meaningful variation.",
  };
}

app.post("/api/style", async (req, res) => {
  try {
    const {
      occasion,
      request,
      wardrobe = [],
      selectedItems = [],
      stylePreferences = {},
      aesthetic = "",
      savedLooks = [],
    } = req.body;

    // ------------------------------------------------
    // VALIDATION
    // ------------------------------------------------

    if (!occasion && !request) {
      return res.status(400).json({
        success: false,
        error:
          "Please provide an occasion or styling request.",
      });
    }

    if (!Array.isArray(wardrobe)) {
      return res.status(400).json({
        success: false,
        error: "Wardrobe must be an array.",
      });
    }

    if (!Array.isArray(selectedItems)) {
      return res.status(400).json({
        success: false,
        error:
          "Selected wardrobe items must be an array.",
      });
    }

    // ------------------------------------------------
    // PREPARE USER DATA
    // ------------------------------------------------

    const wardrobeText = JSON.stringify(
      wardrobe,
      null,
      2
    );

    const selectedItemsText = JSON.stringify(
      selectedItems,
      null,
      2
    );

    const preferencesText = JSON.stringify(
      stylePreferences,
      null,
      2
    );

    const savedLooksText = JSON.stringify(
      savedLooks,
      null,
      2
    );

    // ------------------------------------------------
    // STYLE INTENT + LOOK ARCHITECTURE
    // ------------------------------------------------

    const styleIntent = buildStyleIntent({
      occasion,
      request,
      stylePreferences,
      aesthetic,
    });

    const lookBriefs = buildLookBriefs(styleIntent);
    const styleIntentText = JSON.stringify(
      styleIntent,
      null,
      2
    );
    const lookBriefsText = buildLookBriefText(lookBriefs);

    // ------------------------------------------------
    // SYSTEM PROMPT
    // ------------------------------------------------

    const systemPrompt = `
You are VESTRA, an advanced personal AI fashion stylist.

You are NOT a simple outfit generator.

You are a reasoning-based fashion intelligence system.

Your responsibility is to understand the user's:

- real-world occasion
- current natural-language styling request
- complete wardrobe
- selected wardrobe items
- established style preferences
- personal aesthetic
- saved looks
- current style intent

Then make intelligent decisions about what should actually be worn.

Your goal is to create three COMPLETE, believable and contextually
appropriate outfits that all satisfy the SAME current styling brief
while providing genuinely different creative interpretations.

Do not mechanically combine clothing pieces.

Do not blindly obey wardrobe selections.

Do not treat saved preferences as a closed list of allowed clothing.

Do not make three nearly identical outfits merely because the user
asked for three options.

Think like an expert human stylist with strong fashion literacy.

==================================================
STYLE INTELLIGENCE MODEL
==================================================

Vestra has FOUR different sources of styling information:

1. CURRENT REQUEST
2. EXPLICIT CURRENT RESTRICTIONS OR REQUIREMENTS
3. SAVED PERSONAL PREFERENCES
4. WARDROBE FACTS

They are NOT interchangeable.

The wardrobe tells you WHAT THE USER OWNS.

The saved preferences tell you WHAT THE USER TENDS TO LIKE.

The current request tells you WHAT THE USER WANTS NOW.

Explicit current restrictions tell you WHAT MUST NOT be used or what
must be strongly respected for this request.

Never confuse ownership with preference.

Owning a cream shoe does NOT mean the user wants cream shoes.

Owning a silver watch does NOT mean the user wants a silver watch.

Owning a blazer does NOT mean the blazer belongs in every outfit.

==================================================
CURRENT REQUEST HAS CONTEXTUAL PRIORITY
==================================================

The user's current natural-language request is a temporary styling brief.

It can introduce style directions that do not exist in the saved profile.

Examples:

"I want something luxurious."

"Make it feminine."

"I want a masculine, classy date-night look."

"Preferably a dress."

"I want something dramatic."

"Give me a statement look."

Treat these as CURRENT styling instructions.

Do not require the user to first save these words in their profile.

If the user says "preferably a dress":

- actively search for compatible dresses
- give dresses strong priority when the wardrobe supports them
- do not casually replace a suitable dress with trousers
- do not interpret "preferably" as an absolute prohibition on alternatives
- a non-dress may remain a valid alternative only when it is genuinely strong
  or when a suitable dress is unavailable/incompatible

If the user says "luxurious":

- recognize luxury from material, construction, silhouette, polish,
  restraint, accessories, footwear, proportion and context
- do not wait for "luxury" to appear in saved preferences

If the user says "feminine":

- preserve a clearly feminine styling direction across the looks
- do not introduce a masculine styling direction merely to create variety

If the user says "masculine":

- preserve a clearly masculine styling direction across the looks
- do not introduce a feminine styling direction merely to create variety

These are styling directions, NOT assumptions about the user's identity.

==================================================
STYLE PREFERENCES — SOFT PERSONALIZATION
==================================================

The user's saved style preferences describe ESTABLISHED FASHION TENDENCIES.

They are NOT a closed list of what the user is allowed to wear.

They are NOT hard restrictions unless the user explicitly states that
something should be avoided.

If the user's saved colors are black, cream and white, those colors should
receive more styling weight when relevant.

It does NOT mean:

"Never use burgundy."

If burgundy exists in the wardrobe and is stronger for the current request,
use it.

If the user's saved styles include Afro-Fusion and Minimalist, incorporate
those directions when they genuinely improve the outfit.

It does NOT mean every outfit must visibly contain every saved preference.

If the user's profile does not contain:

- luxury
- feminine
- editorial
- avant-garde
- romantic
- dramatic

Vestra may STILL use those directions when they are supported by the
current request, garment characteristics, occasion, aesthetic and overall
fashion context.

For example:

BURGUNDY + SATIN + EVENING DRESS

may support:

- elegance
- sophistication
- luxury
- romance
- drama

when the occasion and surrounding pieces support that interpretation.

Do not automatically force these descriptors. Recognize them as possible
styling relationships.

==================================================
PREFERENCE VS REQUIREMENT
==================================================

SOFT PREFERENCE:

"I usually like feminine looks."

This influences styling but does not make every outfit feminine.

STRONG CURRENT REQUEST:

"Give me a feminine look tonight."

This receives substantially more weight for this styling request.

EXPLICIT AVOIDANCE:

"I don't want wide-leg trousers."

This becomes a genuine restriction for the current request.

IMPORTANT:

Do NOT infer negative preferences from missing preferences.

The absence of a color, style, fit, material, silhouette or aesthetic from
the saved profile does NOT mean the user dislikes it.

Likewise, do NOT invent restrictions the user never stated.

==================================================
FASHION INTELLIGENCE
==================================================

Do not require the user to manually register every possible fashion concept.

Vestra must make reasonable contextual fashion connections.

Consider relationships among:

- color
- material
- texture
- silhouette
- proportion
- construction
- length
- drape
- sheen
- visual weight
- formality
- occasion
- styling direction

Examples:

BURGUNDY SATIN DRESS + EVENING DATE
can naturally support an elegant, feminine, romantic or luxurious direction.

SHARP BLACK TAILORING + EVENING DATE
can naturally support a polished, commanding or luxurious direction.

A NEUTRAL SNEAKER
does NOT automatically mean sporty.

A CREAM SHOE
does NOT automatically mean classy, sporty or luxury.

A SILVER WATCH
does NOT automatically belong in every polished outfit.

If metadata is missing or says "Unknown", treat that property as uncertain.
Use the wider wardrobe context and current request to decide.
Do not invent certainty.

==================================================
NO CHECKLIST STYLING
==================================================

Do not attempt to satisfy every saved preference simultaneously.

Do not build outfits by mechanically checking boxes.

Determine which information is most relevant to the current request.

A strong outfit may use:

- one major aesthetic direction
- one preferred silhouette
- one preferred color relationship
- one statement element

while introducing other fashion elements that improve the composition.

The objective is a coherent outfit, not a checklist.

==================================================
WARDROBE UNDERSTANDING
==================================================

Understand categories including:

- Tops
- Bottoms
- Dresses
- Skirts
- Jumpsuits
- Shoes
- Outerwear
- Accessories
- Bags
- Headwear
- Activewear
- Swimwear
- Traditional Wear
- Pet Clothing
- Other fashion pieces

Understand:

- garment type
- silhouette
- fit
- length
- color
- pattern
- material
- texture
- proportions
- visual weight
- formality
- practicality
- styling potential
- statement value
- layering potential

Use only information supplied by the wardrobe unless making a reasonable
fashion inference from visible/descriptive characteristics.

DO NOT invent wardrobe items.

DO NOT invent wardrobe IDs.

==================================================
WARDROBE OWNERSHIP VS STYLING SUITABILITY
==================================================

Every wardrobe item is an AVAILABLE OPTION, not a command.

Before using an item, ask:

1. Does it support the current request?
2. Does it support the occasion?
3. Does its formality fit?
4. Does its silhouette work with the composition?
5. Does its color/material help the look?
6. Does it provide useful contrast or texture?
7. Is it genuinely stronger than the alternatives?

Do NOT use an item simply because it exists.

Do NOT repeatedly use the same generic accessory just because it is available.

If a neutral shoe, watch, bag or accessory does not clearly improve the look,
leave it out.

==================================================
COMPLETE WARDROBE
==================================================

Consider the COMPLETE wardrobe.

Search across all relevant categories rather than stopping at the first
acceptable item.

Look for:

- compatible tops
- compatible bottoms
- dresses
- skirts
- jumpsuits
- footwear
- outerwear
- bags
- accessories
- headwear
- statement pieces
- practical pieces

Do not force every wardrobe item into the outfit.

Choose only the strongest combination.

==================================================
OCCASION COMPATIBILITY
==================================================

Treat the occasion as a real-world constraint.

Consider:

- formality
- venue
- activity
- expected movement
- comfort
- practicality
- social context
- weather when supplied
- dress code when supplied
- cultural context when supplied
- time of day when supplied

Do not use rigid templates.

A date can be romantic, minimalist, luxurious, dramatic, casual or
fashion-forward depending on the request and setting.

A classy or luxurious request does NOT automatically mean one exact outfit
formula.

==================================================
SELECTED ITEM EVALUATION
==================================================

Selected wardrobe items receive HIGH ATTENTION, but they do not receive
absolute priority unless the user explicitly makes them a requirement.

Classify each selected item internally as:

- ideal
- workable
- conditional
- incompatible

IDEAL:
Naturally supports the occasion and current request.

WORKABLE:
Works well with the right surrounding pieces.

CONDITIONAL:
Can work only under a specific styling interpretation.

INCOMPATIBLE:
Conflicts strongly with the occasion or current request.

If a selected item is clearly incompatible, do not force it into the primary
outfit.

If it is unconventional but workable, do not reject it merely because it is
unconventional.

==================================================
STRONG REQUIREMENTS
==================================================

Distinguish between:

"Style me around these shoes."

and:

"I am wearing these shoes tonight. Build the outfit around them."

The second is a strong current requirement.

Still preserve basic occasion compatibility.

Do not knowingly create an absurd or unusable outfit.

==================================================
DRESSES AND ONE-PIECE GARMENTS
==================================================

Treat these as complete garments:

- dresses
- maxi dresses
- gowns
- jumpsuits
- rompers
- other one-piece garments

NEVER transform a dress into a shirt.

NEVER transform a dress into trousers.

NEVER split a one-piece garment into imaginary separate garments.

If a suitable dress exists and the current request strongly prefers a dress,
do not casually abandon it for trousers merely to create variety.

If the same dress remains the strongest anchor for multiple looks, it is
acceptable to use that dress across multiple looks while changing the styling
architecture substantially.

==================================================
FOOTWEAR INTELLIGENCE
==================================================

Footwear must be evaluated by context, not by color alone.

Consider:

- construction
- material
- shape
- finish
- silhouette
- formality
- occasion
- outfit architecture
- user request

For a classy/luxurious formal or date-night direction:

- polished formal footwear, heels, dress shoes, refined boots or similarly
  elevated options should receive strong consideration when available
- sneakers should NOT be inserted merely because they are in the wardrobe

However, sneakers may be correct when the user explicitly requests:

- sneaker-luxe
- contemporary street-luxe
- fashion-forward casual
- a deliberately subversive formal/casual contrast

Do not treat sneakers as universally wrong.

Do not treat formal shoes as universally correct.

==================================================
SAVED LOOKS
==================================================

Saved looks may reveal established fashion tendencies.

Use them as evidence of:

- recurring silhouettes
- color preferences
- preferred proportions
- aesthetic
- styling patterns

Do not simply copy old outfits.

==================================================
ALTERNATIVES
==================================================

If the requested item is unavailable, find the closest available wardrobe
alternative while preserving as much of the user's intention as possible.

If a selected item is incompatible, search the wardrobe for another item
that preserves the intended:

- category
- silhouette
- color
- mood
- aesthetic
- function
- statement level

==================================================
MISSING PIECES
==================================================

If the wardrobe lacks an important item:

Do not pretend it exists.

Place it under "missingPieces" or "suggestedPieces".

Be specific.

==================================================
THREE-LOOK CREATIVE ARCHITECTURE
==================================================

Vestra does NOT create three random outfits.

Each look has a different creative JOB.

${lookBriefsText}

The three looks must all satisfy the same current request.

Do NOT create diversity by violating the request.

For example, if the request is feminine, luxurious and date-night:

- all three looks must remain feminine
- all three must remain luxurious
- all three must remain appropriate for the date context

They can differ through:

- silhouette framing
- footwear
- accessory architecture
- layering
- proportions
- color relationships
- texture
- drama
- styling treatment

If a suitable dress is the strongest wardrobe anchor, it may remain across
all three looks while the surrounding styling architecture changes.

If the wardrobe offers multiple strong primary garments, use them to create
meaningful alternatives where appropriate.

Do not swap a strong feminine dress for a masculine trouser look merely to
make the options different.

Likewise, if the request is masculine and luxurious, do not create one look
that suddenly becomes feminine merely to satisfy variety.

==================================================
DIVERSITY REQUIREMENT
==================================================

The three looks must differ across AT LEAST TWO meaningful dimensions each.

Useful diversity dimensions include:

- primary silhouette
- primary garment
- layering architecture
- footwear direction
- accessory direction
- proportion
- color relationship
- texture
- visual drama
- styling mood

Merely changing one watch or one shoe color is NOT enough.

Do not create three copies with different adjectives.

Every look must have a distinct:

- lookRole
- stylingDirection
- variationAxes

==================================================
COMPLETE OUTFIT
==================================================

Think from head to toe.

Consider:

- main garment
- supporting garments
- footwear
- outerwear
- accessories
- bag
- headwear when appropriate

Create ONE believable composition.

Do not output a random list of attractive items.

==================================================
STYLING REASONING
==================================================

For every look, explain WHY it works.

Explain important decisions around:

- occasion compatibility
- current request
- garment compatibility
- selected-item decisions
- styling choices
- personal-style connection
- aesthetic direction
- why this look is distinct from the other two

If an important selected item was rejected, explain naturally.

==================================================
VISUAL PROMPT
==================================================

Every visualPrompt must describe ONE COMPLETE OUTFIT.

Never describe unrelated individual garments.

Describe:

- complete outfit
- garment relationships
- silhouette
- colors
- materials
- footwear
- accessories
- styling direction
- overall fashion character
- visual presentation

The eventual visual direction is:

ghost mannequin / invisible mannequin.

Do not describe a human face.

==================================================
OUTPUT FORMAT
==================================================

Return ONLY valid JSON.

Return exactly:

{
  "looks": [
    {
      "lookRole": "REFINED | STATEMENT | ALTERNATIVE",
      "outfitName": "string",
      "description": "string",
      "reasoning": "string",
      "stylingDirection": "string",
      "presentationDirection": "string",
      "variationAxes": ["string", "string"],
      "selectedItemIds": ["string"],
      "suggestedPieces": [
        {
          "name": "string",
          "category": "string",
          "color": "string",
          "fit": "string",
          "notes": "string"
        }
      ],
      "missingPieces": [
        {
          "name": "string",
          "category": "string",
          "color": "string",
          "fit": "string",
          "notes": "string"
        }
      ],
      "recommendations": ["string"],
      "visualPrompt": "string"
    }
  ]
}

==================================================
OUTPUT RULES
==================================================

Return EXACTLY THREE looks.

The order MUST be:

1. REFINED
2. STATEMENT
3. ALTERNATIVE

selectedItemIds MUST contain only IDs that actually exist in the supplied
wardrobe.

NEVER invent wardrobe IDs.

If a selected item is incompatible and is not used, do not include its ID.

Do not claim an item was used when it was not.

Suggested pieces are NOT wardrobe pieces.

Do not give suggested pieces fake wardrobe IDs.

Every look must be a complete outfit.

Every look must be internally coherent.

Every look must satisfy the same current request.

Every look must be meaningfully different.

Do not repeatedly add the same generic cream shoe, silver watch, black bag
or other accessory unless that specific item is genuinely the strongest
choice for that particular look.

Every visualPrompt must describe ONE complete outfit.

Every presentationDirection must describe HOW that specific outfit should be visually presented.

Choose the presentation that best communicates the actual garments, silhouette, proportions, layering, accessories, and styling intent of that look.

Presentation directions may include, when appropriate:
- full-body fashion editorial
- ghost mannequin / invisible model
- garment-focused studio presentation
- editorial model presentation with the face excluded
- dynamic fashion pose emphasizing movement and silhouette
- seated or posed editorial presentation when it better communicates the outfit
- close-up garment/detail presentation when material, construction, or accessories are important
- flat-lay or arranged garment presentation when the outfit is best understood as a coordinated composition

Do NOT choose a presentation merely for variety.

The presentation must be appropriate to the specific outfit, occasion, garment structure, and styling direction.

For example:
- A structured suit may benefit from a full-body editorial presentation showing its tailoring and proportions.
- A dramatic statement coat may benefit from a dynamic editorial presentation that shows its silhouette and movement.
- A detailed dress may benefit from a presentation that clearly shows its length, drape, slit, neckline, and overall silhouette.
- A layered outfit may benefit from a full-body presentation where every layer remains clearly visible.
- Accessories or intricate garment details may require a closer garment-focused presentation.

Do not introduce a recognizable real person, celebrity, or unrelated model identity.

Every presentationDirection must be specific enough for the image-generation system to understand the intended composition.

Return nothing outside the JSON.
`;

    // ------------------------------------------------
    // USER PROMPT
    // ------------------------------------------------

    const userPrompt = `
Create three intelligent, compatibility-aware complete fashion looks for
this Vestra user.

==================================================
OCCASION
==================================================

${occasion || "Not specified"}

==================================================
CURRENT USER REQUEST
==================================================

${
  request ||
  "Create the strongest possible outfit from the available wardrobe."
}

==================================================
EXTRACTED CURRENT STYLE INTENT
==================================================

${styleIntentText}

==================================================
THREE LOOK CREATIVE BRIEFS
==================================================

${lookBriefsText}

==================================================
SAVED STYLE PREFERENCES
==================================================

${preferencesText}

==================================================
PERSONAL AESTHETIC
==================================================

${aesthetic || "Not specified"}

==================================================
SELECTED WARDROBE ITEMS
==================================================

${selectedItemsText}

==================================================
COMPLETE WARDROBE
==================================================

${wardrobeText}

==================================================
PREVIOUSLY SAVED LOOKS
==================================================

${savedLooksText}

==================================================
FINAL STYLING PROCESS
==================================================

Before producing the final JSON, internally perform this process:

1. Understand the occasion.
2. Extract the user's CURRENT styling intent.
3. Separate current instructions from saved preferences.
4. Identify explicit requirements and explicit avoidances.
5. Inspect every selected item.
6. Evaluate every selected item for compatibility.
7. Inspect the COMPLETE wardrobe.
8. Identify the strongest compatible wardrobe candidates.
9. Determine whether selected items should be used, adapted, conditional or rejected.
10. Evaluate footwear and accessories contextually rather than by color alone.
11. Check compatibility between all chosen pieces.
12. Apply relevant saved preferences as soft personalization.
13. Apply the user's aesthetic.
14. Build Look 1 according to the REFINED brief.
15. Build Look 2 according to the STATEMENT brief.
16. Build Look 3 according to the ALTERNATIVE brief.
17. Ensure all three still satisfy the SAME current request.
18. Ensure each look differs across at least two meaningful dimensions.
19. Ensure a preferred garment type such as a dress is not casually abandoned when a strong compatible option exists.
20. Identify genuinely missing pieces.
21. Explain important styling decisions.
22. Create one complete visualPrompt for each outfit.

Remember:

The wardrobe describes ownership, not preference.

Saved preferences describe tendencies, not absolute rules.

The current request is the temporary styling brief for THIS request.

Explicit avoidance is stronger than an absent preference.

Do not invent restrictions.

Do not force inappropriate garments.

Do not reject unconventional garments merely because they are unconventional.

Do not create three nearly identical looks.

Do not make one look masculine and another feminine merely to create variety
when the current request clearly establishes one styling direction.

The objective is three genuinely different interpretations of the BEST POSSIBLE
styling response to the same occasion and request.

Return exactly three looks.

Return only valid JSON.
`;

    // ------------------------------------------------
    // CALL AI
    // ------------------------------------------------

    let parsed = await callOpenAI({
      systemPrompt,
      userPrompt,
      temperature: 0.78,
    });

    // ------------------------------------------------
    // VALIDATE RESPONSE SHAPE
    // ------------------------------------------------

    if (!parsed || !Array.isArray(parsed.looks)) {
      return res.status(500).json({
        success: false,
        error:
          "AI response did not contain a valid looks array.",
      });
    }

    let looks = parsed.looks.slice(0, 3);

    if (looks.length !== 3) {
      return res.status(500).json({
        success: false,
        error: "AI did not generate exactly three looks.",
      });
    }

    // ------------------------------------------------
    // VALIDATE WARDROBE IDS + NORMALIZE LOOK METADATA
    // ------------------------------------------------

    const validWardrobeIds = new Set(
      wardrobe
        .map((item) => item?.id)
        .filter(
          (id) =>
            id !== undefined &&
            id !== null
        )
        .map((id) => String(id))
    );

    const sanitizeLooks = (rawLooks) =>
      rawLooks.map((look) => {
        const selectedIds =
          Array.isArray(look?.selectedItemIds)
            ? look.selectedItemIds
                .map((id) => String(id))
                .filter((id) => validWardrobeIds.has(id))
            : [];

        const variationAxes =
          Array.isArray(look?.variationAxes)
            ? look.variationAxes
                .map((axis) => String(axis).trim())
                .filter(Boolean)
                .slice(0, 6)
            : [];

        return {
          ...look,
          lookRole: String(look?.lookRole || "")
            .trim()
            .toUpperCase(),
          selectedItemIds: selectedIds,
          variationAxes,
        };
      });

    looks = sanitizeLooks(looks);

    // ------------------------------------------------
    // STRUCTURAL DIVERSITY CHECK
    // ------------------------------------------------

    let diversityCheck = validateLookDiversity(looks);

    // Give the model one repair opportunity if it returned three looks but
    // failed Vestra's stronger diversity contract.
    if (!diversityCheck.valid) {
      console.warn(
        "Vestra look diversity check failed:",
        diversityCheck.reason
      );

      const repairSystemPrompt = `${systemPrompt}

==================================================
DIVERSITY REPAIR MODE
==================================================

The previous response failed Vestra's structural diversity check.

Failure reason:
${diversityCheck.reason}

Generate the three looks again.

You MUST preserve the user's current styling intent and any valid explicit
requirements.

You MUST keep the exact creative roles:

1. REFINED
2. STATEMENT
3. ALTERNATIVE

Make the three outfits materially different across at least two meaningful
dimensions while keeping the same requested styling direction.

Do not create diversity by violating the user's request.

Return only valid JSON in the required format.
`;

      const repairUserPrompt = `${userPrompt}

==================================================
REPAIR REQUEST
==================================================

The first generation was rejected because:
${diversityCheck.reason}

Regenerate all three looks from scratch using the three creative briefs.
Make the differences structural and visible, not merely descriptive.
`;

      parsed = await callOpenAI({
        systemPrompt: repairSystemPrompt,
        userPrompt: repairUserPrompt,
        temperature: 0.85,
      });

      if (!parsed || !Array.isArray(parsed.looks)) {
        return res.status(500).json({
          success: false,
          error:
            "AI diversity repair did not return a valid looks array.",
        });
      }

      looks = parsed.looks.slice(0, 3);

      if (looks.length !== 3) {
        return res.status(500).json({
          success: false,
          error:
            "AI diversity repair did not generate exactly three looks.",
        });
      }

      looks = sanitizeLooks(looks);
      diversityCheck = validateLookDiversity(looks);
    }

    // Never silently present three near-duplicate looks if the repair also
    // failed. The client receives a useful error and can retry.
    if (!diversityCheck.valid) {
      return res.status(500).json({
        success: false,
        error:
          "Vestra could not generate three sufficiently distinct looks for this request.",
        details: diversityCheck.reason,
      });
    }

    // ------------------------------------------------
    // RETURN TO FLUTTER
    // ------------------------------------------------

    return res.json({
      success: true,
      looks,
    });

  } catch (error) {
    console.error(
      "Vestra stylist error:",
      error
    );

    return res.status(
      error.status || 500
    ).json({
      success: false,
      error:
        error.message ||
        "Vestra backend encountered an unexpected error.",
      ...(error.details
        ? {
            details: error.details,
          }
        : {}),
    });
  }
});

// ==================================================
// WARDROBE PHOTO RECOGNITION
// ==================================================

app.post(
  "/api/wardrobe/analyze",
  async (req, res) => {
    try {
      const {
        imageBase64,
      } = req.body;

      // ----------------------------------------------
      // VALIDATION
      // ----------------------------------------------

      if (
        !imageBase64 ||
        typeof imageBase64 !== "string" ||
        imageBase64.trim().length === 0
      ) {
        return res.status(400).json({
          success: false,
          error:
            "No clothing photo was provided.",
        });
      }

      if (!OPENAI_API_KEY) {
        return res.status(500).json({
          success: false,
          error:
            "OPENAI_API_KEY is not configured on the server.",
        });
      }

      // ----------------------------------------------
      // NORMALIZE IMAGE
      // ----------------------------------------------

      let imageUrl =
        imageBase64.trim();

      if (
        !imageUrl.startsWith("data:image/")
      ) {
        imageUrl =
          `data:image/jpeg;base64,${imageUrl}`;
      }

      // ----------------------------------------------
      // VISION PROMPT
      // ----------------------------------------------

      const systemPrompt = `
You are VESTRA Vision, a professional fashion garment
recognition system.

Analyze the clothing item in the supplied image.

Your job is to identify the CLOTHING ITEM accurately.

Do not identify or describe the person.

==================================================
IMPORTANT
==================================================

Do not assume the wearer's gender.

Identify the clothing item.

If the item is a dress, identify it as a dress.

If it is a maxi dress, identify it as a maxi dress.

If it is a gown, identify it as a gown or appropriate dress type.

Do not turn dresses into tops or trousers.

Do not invent details that cannot reasonably be seen.

When a property cannot reasonably be determined from the image,
return "Unknown".

==================================================
CATEGORIES
==================================================

Use one of these categories whenever possible:

Tops
Bottoms
Dresses
Skirts
Jumpsuits
Shoes
Outerwear
Accessories
Bags
Headwear
Activewear
Swimwear
Traditional Wear
Pet Clothing
Other

==================================================
OUTPUT
==================================================

Return ONLY valid JSON:

{
  "item": {
    "name": "string",
    "category": "string",
    "color": "string",
    "style": "string",
    "fit": "string",
    "length": "string",
    "material": "string",
    "pattern": "string",
    "notes": "string"
  }
}

The name should be useful and natural.

Example:

"Black Maxi Dress"

instead of:

"Dress"

when the image clearly supports the more specific description.

Return nothing outside the JSON.
`;

      // ----------------------------------------------
      // DIRECT VISION REQUEST
      // ----------------------------------------------

      const response =
        await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",

            headers: {
              "Content-Type":
                "application/json",
              Authorization:
                `Bearer ${OPENAI_API_KEY}`,
            },

            body: JSON.stringify({
              model: OPENAI_MODEL,

              messages: [
                {
                  role: "system",
                  content: systemPrompt,
                },
                {
                  role: "user",
                  content: [
                    {
                      type: "text",
                      text:
                        "Identify and describe this clothing item.",
                    },
                    {
                      type: "image_url",
                      image_url: {
                        url: imageUrl,
                      },
                    },
                  ],
                },
              ],

              temperature: 0.2,

              response_format: {
                type: "json_object",
              },
            }),
          }
        );

      // ----------------------------------------------
      // HANDLE AI ERROR
      // ----------------------------------------------

      if (!response.ok) {
        const errorText =
          await response.text();

        console.error(
          "Wardrobe vision error:",
          errorText
        );

        return res.status(
          response.status
        ).json({
          success: false,
          error:
            "Vestra could not analyze this clothing photo.",
          details: errorText,
        });
      }

      // ----------------------------------------------
      // READ RESPONSE
      // ----------------------------------------------

      const data =
        await response.json();

      const content =
        data?.choices?.[0]?.message?.content;

      if (!content) {
        return res.status(500).json({
          success: false,
          error:
            "The AI returned an empty recognition response.",
        });
      }

      // ----------------------------------------------
      // PARSE JSON
      // ----------------------------------------------

      let parsed;

      try {
        parsed =
          JSON.parse(content);
      } catch (error) {
        console.error(
          "Invalid wardrobe AI JSON:",
          content
        );

        return res.status(500).json({
          success: false,
          error:
            "The AI returned invalid clothing information.",
        });
      }

      // ----------------------------------------------
      // VALIDATE ITEM
      // ----------------------------------------------

      if (
        !parsed ||
        typeof parsed.item !== "object" ||
        parsed.item === null
      ) {
        return res.status(500).json({
          success: false,
          error:
            "Vestra did not receive valid clothing information.",
        });
      }

      const item =
        parsed.item;

      // ----------------------------------------------
      // NORMALIZE RESPONSE
      // ----------------------------------------------

      const normalizedItem = {
        name:
          cleanValue(
            item.name,
            "Clothing item"
          ),

        category:
          cleanValue(
            item.category,
            "Other"
          ),

        color:
          cleanValue(
            item.color,
            "Unknown"
          ),

        style:
          cleanValue(
            item.style,
            "Unknown"
          ),

        fit:
          cleanValue(
            item.fit,
            "Unknown"
          ),

        length:
          cleanValue(
            item.length,
            "Unknown"
          ),

        material:
          cleanValue(
            item.material,
            "Unknown"
          ),

        pattern:
          cleanValue(
            item.pattern,
            "Unknown"
          ),

        notes:
          cleanValue(
            item.notes,
            ""
          ),
      };

      // ----------------------------------------------
      // RETURN TO FLUTTER
      // ----------------------------------------------

      return res.json({
        success: true,
        item: normalizedItem,
      });

    } catch (error) {
      console.error(
        "Wardrobe recognition server error:",
        error
      );

      return res.status(
        error.status || 500
      ).json({
        success: false,
        error:
          error.message ||
          "Vestra backend encountered an unexpected error.",
      });
    }
  }
);

// ==================================================
// STYLE PROFILE ANALYSIS
// ==================================================

app.post(
  "/api/style/analyze",
  async (req, res) => {
    try {
      const {
        wardrobe = [],
        stylePreferences = {},
        aesthetic = "",
        savedLooks = [],
      } = req.body;

      const systemPrompt = `
You are VESTRA, an advanced personal fashion intelligence system.

Analyze the user's fashion data and identify their strongest
style characteristics.

Consider:

- wardrobe composition
- colors
- silhouettes
- preferred styles
- fits
- aesthetic
- saved outfits
- recurring patterns

Do not assume gender.

Do not invent information.

Return ONLY valid JSON:

{
  "styleProfile": {
    "primaryStyle": "string",
    "secondaryStyles": ["string"],
    "aesthetic": "string",
    "preferredSilhouettes": ["string"],
    "preferredColors": ["string"],
    "strengths": ["string"],
    "styleDirections": ["string"],
    "recommendations": ["string"]
  }
}
`;

      const userPrompt = `
WARDROBE:

${JSON.stringify(
  wardrobe,
  null,
  2
)}

STYLE PREFERENCES:

${JSON.stringify(
  stylePreferences,
  null,
  2
)}

AESTHETIC:

${aesthetic || "Not specified"}

SAVED LOOKS:

${JSON.stringify(
  savedLooks,
  null,
  2
)}
`;

      const parsed =
        await callOpenAI({
          systemPrompt,
          userPrompt,
          temperature: 0.5,
        });

      if (
        !parsed ||
        !parsed.styleProfile
      ) {
        return res.status(500).json({
          success: false,
          error:
            "AI did not return a valid style profile.",
        });
      }

      return res.json({
        success: true,
        styleProfile:
          parsed.styleProfile,
      });

    } catch (error) {
      console.error(
        "Style analysis error:",
        error
      );

      return res.status(
        error.status || 500
      ).json({
        success: false,
        error:
          error.message ||
          "Vestra could not analyze the user's style.",
      });
    }
  }
);

// ==================================================
// RECOMMENDATIONS
// ==================================================

app.post(
  "/api/recommendations",
  async (req, res) => {
    try {
      const {
        wardrobe = [],
        stylePreferences = {},
        aesthetic = "",
        savedLooks = [],
        occasion = "",
      } = req.body;

      const systemPrompt = `
You are VESTRA, a personal fashion recommendation engine.

Recommend useful fashion directions based on the user's actual
wardrobe and preferences.

Do not assume gender.

Prioritize recommendations that can realistically work with the
user's wardrobe.

Do not invent wardrobe items.

Return ONLY valid JSON:

{
  "recommendations": [
    {
      "title": "string",
      "description": "string",
      "reason": "string",
      "relatedWardrobeItems": ["number"]
    }
  ]
}

Return exactly 5 recommendations.
`;

      const userPrompt = `
WARDROBE:

${JSON.stringify(
  wardrobe,
  null,
  2
)}

STYLE PREFERENCES:

${JSON.stringify(
  stylePreferences,
  null,
  2
)}

AESTHETIC:

${aesthetic || "Not specified"}

SAVED LOOKS:

${JSON.stringify(
  savedLooks,
  null,
  2
)}

CURRENT OCCASION:

${occasion || "Not specified"}
`;

      const parsed =
        await callOpenAI({
          systemPrompt,
          userPrompt,
          temperature: 0.7,
        });

      if (
        !parsed ||
        !Array.isArray(
          parsed.recommendations
        )
      ) {
        return res.status(500).json({
          success: false,
          error:
            "AI did not return valid recommendations.",
        });
      }

      return res.json({
        success: true,
        recommendations:
          parsed.recommendations.slice(
            0,
            5
          ),
      });

    } catch (error) {
      console.error(
        "Recommendation error:",
        error
      );

      return res.status(
        error.status || 500
      ).json({
        success: false,
        error:
          error.message ||
          "Vestra could not create recommendations.",
      });
    }
  }
);

// ==================================================
// TRENDS
// VESTRA TREND INTELLIGENCE
// ==================================================

const trendsCache = new Map();

const TRENDS_CACHE_DURATION =
  30 * 60 * 1000;

// --------------------------------------------------
// POST /api/trends
// Personalized trend feed
// --------------------------------------------------

app.post(
  "/api/trends",
  async (req, res) => {
    try {
      const {
        stylePreferences = {},
        aesthetics = [],
      } = req.body || {};

      // ----------------------------------------------
      // NORMALIZE USER PREFERENCES
      // ----------------------------------------------

      const styles =
        Array.isArray(
          stylePreferences?.styles
        )
          ? stylePreferences.styles
              .map((style) =>
                String(style).trim()
              )
              .filter(Boolean)
          : [];

      const userAesthetics =
        Array.isArray(aesthetics)
          ? aesthetics
              .map((aesthetic) =>
                String(aesthetic).trim()
              )
              .filter(Boolean)
          : [];

      // ----------------------------------------------
      // CACHE KEY
      // ----------------------------------------------

      const cacheKey =
        JSON.stringify({
          styles,
          aesthetics:
            userAesthetics,
        });

      const cached =
        trendsCache.get(
          cacheKey
        );

      if (
        cached &&
        Date.now() -
            cached.timestamp <
          TRENDS_CACHE_DURATION
      ) {
        return res.json({
          success: true,
          data: cached.data,
        });
      }

      // ----------------------------------------------
      // SYSTEM PROMPT
      // ----------------------------------------------

      const systemPrompt = `
You are VESTRA Trend Intelligence.

You are responsible for producing fashion trend intelligence
for Vestra's personalized fashion discovery experience.

Your job is NOT to invent random outfit ideas.

Your job is to identify useful contemporary fashion directions
that a personal AI stylist can use.

Consider:

- current fashion direction
- contemporary silhouettes
- styling movements
- colors
- materials
- proportions
- layering
- footwear
- accessories
- aesthetics
- streetwear
- tailoring
- luxury
- contemporary African fashion
- Afro-fusion
- minimalist fashion
- avant-garde fashion
- emerging style combinations

IMPORTANT:

Do not present unsupported claims as verified real-time facts.

Do not invent fashion publications, designers, statistics,
runway shows, brands, or social-media trends.

If real-time information is unavailable, describe the result as
fashion trend intelligence or contemporary styling direction
rather than claiming that a specific trend is currently
dominating the fashion industry.

The output should feel useful, modern and fashion-aware.

Personalization matters.

If the user has preferred styles or aesthetics, prioritize
trend directions that naturally intersect with those preferences.

However, do not simply repeat the user's preferences.

Discover meaningful directions within them.

==================================================
TRENDING NOW
==================================================

Create exactly 3 trend directions.

Each should have:

- a concise title
- a useful description
- a category
- a type
- relevant styles
- relevant pieces
- relevant colors
- relevant aesthetics
- a styling direction

==================================================
POPULAR STYLES
==================================================

Create exactly 6 style directions relevant to contemporary fashion.

These should be concise names.

Choose the actual results based on the fashion intelligence
and user preferences.

Do not automatically use example styles.

==================================================
TRENDING PIECES
==================================================

Create exactly 4 individual clothing/accessory pieces that are
useful for contemporary outfit building.

Possible categories include:

- Outerwear
- Tops
- Bottoms
- Shoes
- Accessories
- Bags
- Headwear

Do not automatically copy examples.

==================================================
TREND TIP
==================================================

Create one short, useful styling tip connected to the trend
intelligence.

==================================================
OUTPUT
==================================================

Return ONLY valid JSON.

Use exactly this structure:

{
  "trendingNow": [
    {
      "id": "trend-1",
      "title": "string",
      "description": "string",
      "category": "string",
      "type": "trend",
      "styles": ["string"],
      "pieces": ["string"],
      "colors": ["string"],
      "aesthetics": ["string"],
      "stylingDirection": "string"
    }
  ],
  "popularStyles": [
    "string"
  ],
  "trendingPieces": [
    {
      "id": "piece-1",
      "title": "string",
      "description": "string",
      "category": "string",
      "type": "piece",
      "styles": ["string"],
      "pieces": ["string"],
      "colors": ["string"],
      "aesthetics": ["string"]
    }
  ],
  "trendTip": "string"
}

Return:

- exactly 3 trendingNow items
- exactly 6 popularStyles
- exactly 4 trendingPieces
- exactly 1 trendTip

Return nothing outside the JSON.
`;

      // ----------------------------------------------
      // USER PROMPT
      // ----------------------------------------------

      const userPrompt = `
Generate personalized fashion trend intelligence for Vestra.

USER STYLE PREFERENCES:

${JSON.stringify(
  styles,
  null,
  2
)}

USER AESTHETICS:

${JSON.stringify(
  userAesthetics,
  null,
  2
)}

Use these preferences as personalization signals.

Do not simply repeat them.

Find contemporary fashion directions that naturally fit
the user's fashion identity while still exposing them to
new styling ideas.

The output will be displayed inside Vestra's Trending screen.

Make the results concise, visually understandable and useful
to an AI fashion stylist.

Return only valid JSON.
`;

      // ----------------------------------------------
      // CALL AI
      // ----------------------------------------------

      const parsed =
        await callOpenAI({
          systemPrompt,
          userPrompt,
          temperature: 0.75,
        });

      // ----------------------------------------------
      // VALIDATE RESPONSE
      // ----------------------------------------------

      if (
        !parsed ||
        !Array.isArray(
          parsed.trendingNow
        ) ||
        !Array.isArray(
          parsed.popularStyles
        ) ||
        !Array.isArray(
          parsed.trendingPieces
        ) ||
        typeof parsed.trendTip !==
          "string"
      ) {
        return res.status(500).json({
          success: false,
          error:
            "AI returned an invalid trend response.",
        });
      }

      // ----------------------------------------------
      // NORMALIZE TRENDING NOW
      // ----------------------------------------------

      const trendingNow =
        parsed.trendingNow
          .slice(0, 3)
          .map(
            (trend, index) => ({
              id:
                cleanValue(
                  trend?.id,
                  `trend-${index + 1}`
                ),

              title:
                cleanValue(
                  trend?.title,
                  "Fashion Direction"
                ),

              description:
                cleanValue(
                  trend?.description,
                  "A contemporary styling direction."
                ),

              category:
                cleanValue(
                  trend?.category,
                  "Style"
                ),

              type: "trend",

              imageUrl:
                cleanValue(
                  trend?.imageUrl,
                  ""
                ) || null,

              styles:
                cleanStringArray(
                  trend?.styles
                ),

              pieces:
                cleanStringArray(
                  trend?.pieces
                ),

              colors:
                cleanStringArray(
                  trend?.colors
                ),

              aesthetics:
                cleanStringArray(
                  trend?.aesthetics
                ),

              source:
                cleanValue(
                  trend?.source,
                  ""
                ) || null,

              stylingDirection:
                cleanValue(
                  trend?.stylingDirection,
                  ""
                ),

              updatedAt:
                new Date().toISOString(),
            })
          );

      // ----------------------------------------------
      // NORMALIZE POPULAR STYLES
      // ----------------------------------------------

      const popularStyles =
        parsed.popularStyles
          .map((style) =>
            String(style).trim()
          )
          .filter(Boolean)
          .slice(0, 6);

      // ----------------------------------------------
      // NORMALIZE TRENDING PIECES
      // ----------------------------------------------

      const trendingPieces =
        parsed.trendingPieces
          .slice(0, 4)
          .map(
            (piece, index) => ({
              id:
                cleanValue(
                  piece?.id,
                  `piece-${index + 1}`
                ),

              title:
                cleanValue(
                  piece?.title,
                  "Fashion Piece"
                ),

              description:
                cleanValue(
                  piece?.description,
                  "A contemporary wardrobe piece."
                ),

              category:
                cleanValue(
                  piece?.category,
                  "Fashion"
                ),

              type: "piece",

              imageUrl:
                cleanValue(
                  piece?.imageUrl,
                  ""
                ) || null,

              styles:
                cleanStringArray(
                  piece?.styles
                ),

              pieces:
                cleanStringArray(
                  piece?.pieces
                ),

              colors:
                cleanStringArray(
                  piece?.colors
                ),

              aesthetics:
                cleanStringArray(
                  piece?.aesthetics
                ),

              source:
                cleanValue(
                  piece?.source,
                  ""
                ) || null,

              updatedAt:
                new Date().toISOString(),
            })
          );

      // ----------------------------------------------
      // FINAL DATA
      // ----------------------------------------------

      const trendsData = {
        trendingNow,

        popularStyles,

        trendingPieces,

        trendTip:
          cleanValue(
            parsed.trendTip,
            "Trends are inspiration. The best look is the one that still feels like you."
          ),

        updatedAt:
          new Date().toISOString(),
      };

      // ----------------------------------------------
      // CACHE
      // ----------------------------------------------

      trendsCache.set(
        cacheKey,
        {
          timestamp: Date.now(),
          data: trendsData,
        }
      );

      // ----------------------------------------------
      // RETURN
      // ----------------------------------------------

      return res.json({
        success: true,
        data: trendsData,
      });

    } catch (error) {
      console.error(
        "Vestra trend intelligence error:",
        error
      );

      return res.status(
        error.status || 500
      ).json({
        success: false,
        error:
          error.message ||
          "Vestra could not retrieve fashion trends.",
      });
    }
  }
);

// --------------------------------------------------
// GET /api/trends
// General trend feed / backwards compatibility
// --------------------------------------------------

app.get(
  "/api/trends",
  async (req, res) => {
    try {
      const styles = [];
      const userAesthetics = [];

      const cacheKey =
        JSON.stringify({
          styles,
          aesthetics:
            userAesthetics,
        });

      const cached =
        trendsCache.get(
          cacheKey
        );

      if (
        cached &&
        Date.now() -
            cached.timestamp <
          TRENDS_CACHE_DURATION
      ) {
        return res.json({
          success: true,
          data: cached.data,
        });
      }

      const systemPrompt = `
You are VESTRA Trend Intelligence.

Generate useful contemporary fashion trend intelligence.

Do not assume gender.

Do not invent statistics, publications, designers,
fashion events or unsupported claims of real-time popularity.

Focus on:

- silhouettes
- styling directions
- colors
- materials
- layering
- footwear
- accessories
- contemporary aesthetics
- Afro-fusion
- tailoring
- streetwear
- minimalist fashion
- avant-garde fashion
- luxury fashion

Return ONLY valid JSON:

{
  "trendingNow": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "category": "string",
      "type": "trend",
      "styles": ["string"],
      "pieces": ["string"],
      "colors": ["string"],
      "aesthetics": ["string"],
      "stylingDirection": "string"
    }
  ],
  "popularStyles": ["string"],
  "trendingPieces": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "category": "string",
      "type": "piece",
      "styles": ["string"],
      "pieces": ["string"],
      "colors": ["string"],
      "aesthetics": ["string"]
    }
  ],
  "trendTip": "string"
}

Return exactly:

3 trendingNow items
6 popularStyles
4 trendingPieces
1 trendTip
`;

      const userPrompt = `
Generate a general Vestra fashion trend intelligence feed.

Do not personalize it to a specific user because no
personal style information was supplied.

Return only valid JSON.
`;

      const parsed =
        await callOpenAI({
          systemPrompt,
          userPrompt,
          temperature: 0.75,
        });

      if (
        !parsed ||
        !Array.isArray(
          parsed.trendingNow
        ) ||
        !Array.isArray(
          parsed.popularStyles
        ) ||
        !Array.isArray(
          parsed.trendingPieces
        )
      ) {
        return res.status(500).json({
          success: false,
          error:
            "AI returned an invalid trend response.",
        });
      }

      const now =
        new Date().toISOString();

      const data = {
        trendingNow:
          parsed.trendingNow
            .slice(0, 3)
            .map(
              (trend, index) => ({
                id:
                  cleanValue(
                    trend?.id,
                    `trend-${index + 1}`
                  ),

                title:
                  cleanValue(
                    trend?.title,
                    "Fashion Direction"
                  ),

                description:
                  cleanValue(
                    trend?.description,
                    "A contemporary styling direction."
                  ),

                category:
                  cleanValue(
                    trend?.category,
                    "Style"
                  ),

                type: "trend",

                styles:
                  cleanStringArray(
                    trend?.styles
                  ),

                pieces:
                  cleanStringArray(
                    trend?.pieces
                  ),

                colors:
                  cleanStringArray(
                    trend?.colors
                  ),

                aesthetics:
                  cleanStringArray(
                    trend?.aesthetics
                  ),

                stylingDirection:
                  cleanValue(
                    trend?.stylingDirection,
                    ""
                  ),

                updatedAt: now,
              })
            ),

        popularStyles:
          parsed.popularStyles
            .map((style) =>
              String(style).trim()
            )
            .filter(Boolean)
            .slice(0, 6),

        trendingPieces:
          parsed.trendingPieces
            .slice(0, 4)
            .map(
              (piece, index) => ({
                id:
                  cleanValue(
                    piece?.id,
                    `piece-${index + 1}`
                  ),

                title:
                  cleanValue(
                    piece?.title,
                    "Fashion Piece"
                  ),

                description:
                  cleanValue(
                    piece?.description,
                    "A contemporary wardrobe piece."
                  ),

                category:
                  cleanValue(
                    piece?.category,
                    "Fashion"
                  ),

                type: "piece",

                styles:
                  cleanStringArray(
                    piece?.styles
                  ),

                pieces:
                  cleanStringArray(
                    piece?.pieces
                  ),

                colors:
                  cleanStringArray(
                    piece?.colors
                  ),

                aesthetics:
                  cleanStringArray(
                    piece?.aesthetics
                  ),

                updatedAt: now,
              })
            ),

        trendTip:
          cleanValue(
            parsed.trendTip,
            "Trends are inspiration. The best look is the one that still feels like you."
          ),

        updatedAt: now,
      };

      trendsCache.set(
        cacheKey,
        {
          timestamp: Date.now(),
          data,
        }
      );

      return res.json({
        success: true,
        data,
      });

    } catch (error) {
      console.error(
        "Vestra GET trends error:",
        error
      );

      return res.status(
        error.status || 500
      ).json({
        success: false,
        error:
          error.message ||
          "Vestra could not retrieve fashion trends.",
      });
    }
  }
);

// ==================================================
// OUTFIT GENERATION
// FUTURE IMAGE LAYER
// ==================================================

app.post("/api/outfit/generate", async (req, res) => {
  try {
    const {
  outfit,
  visualStyle = "adaptive editorial presentation",
} = req.body;

    if (!outfit) {
      return res.status(400).json({
        success: false,
        error: "No outfit was provided for visualization.",
      });
    }

    if (!OPENAI_API_KEY) {
      return res.status(500).json({
        success: false,
        error: "OPENAI_API_KEY is not configured.",
      });
    }

    const visualPrompt =
      outfit.visualPrompt?.toString().trim() || "";

    if (!visualPrompt) {
      return res.status(400).json({
        success: false,
        error: "No visual prompt was provided for this outfit.",
      });
    }

    /*
     * Vestra outfit visualization
     *
     * The styling engine creates the outfit structure and
     * visualPrompt. This endpoint sends that prompt to
     * OpenAI's image-generation model and returns the
     * generated image as Base64.
     */

    const imagePrompt = `
Create a high-end fashion editorial image of the following outfit.

Present the outfit using the presentation direction provided below.

The presentation may use a fashion model, ghost mannequin,
garment-focused studio composition, flat-lay, or another editorial
composition when that format best communicates the specific outfit.

IMPORTANT:
- Follow the presentationDirection as the primary composition instruction.
- Keep the complete outfit clearly visible unless the presentationDirection specifically calls for a detail-focused composition.
- If a model is appropriate, use a non-recognizable editorial fashion model whose appearance does not distract from the clothing.
- Never depict a celebrity, public figure, or recognizable real person.
- Keep body proportions and garment proportions realistic.
- Preserve the garment colors, materials, textures, silhouettes,
  layering, proportions, and accessories described in the prompt.
- Preserve the intended fit, drape, length, structure, and styling relationships between garments.
- Present the outfit as a premium high-fashion editorial.
- Use realistic editorial-quality lighting appropriate to the presentation.
- Use a clean, sophisticated setting or background appropriate to the presentation.
- Make the important garments and styling decisions easy to understand.
- Do not add clothing that is not described.
- Do not remove important clothing described in the prompt.
- Do not alter the core outfit merely to make the image more visually dramatic.
Visual presentation style:
${visualStyle}

Outfit name:
${outfit.outfitName || "Vestra Look"}

Styling direction:
${outfit.stylingDirection || ""}

Presentation direction:
${outfit.presentationDirection || ""}

Detailed visual prompt:
${visualPrompt}
`;

    const response = await fetch(
      "https://api.openai.com/v1/images/generations",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: OPENAI_IMAGE_MODEL,
          prompt: imagePrompt,
          size: "1024x1024",
        }),
      }
    );

    const responseText = await response.text();

    let decoded;

    try {
      decoded = JSON.parse(responseText);
    } catch (parseError) {
      console.error(
        "OpenAI image response was not valid JSON:",
        responseText
      );

      return res.status(502).json({
        success: false,
        error: "Vestra received an invalid response from the image-generation service.",
      });
    }

    if (!response.ok) {
      console.error(
        "OpenAI image-generation error:",
        JSON.stringify(decoded, null, 2)
      );

      return res.status(response.status).json({
        success: false,
        error:
          decoded?.error?.message ||
          "The image-generation service returned an error.",
      });
    }

    /*
     * OpenAI may return the generated image as Base64.
     */
    const imageBase64 =
      decoded?.data?.[0]?.b64_json?.toString().trim() || "";

    if (!imageBase64) {
      console.error(
        "OpenAI image response did not contain Base64 image data:",
        JSON.stringify(decoded, null, 2)
      );

      return res.status(502).json({
        success: false,
        error: "Vestra received an empty image from the image-generation service.",
      });
    }

    return res.json({
      success: true,
      imageBase64,
      visualStyle,
      outfitName: outfit.outfitName || "Vestra Look",
    });
  } catch (error) {
    console.error(
      "Vestra outfit image-generation error:",
      error
    );

    return res.status(500).json({
      success: false,
      error:
        error?.message ||
        "Something went wrong while generating the outfit image.",
    });
  }
});

// ==================================================
// FULL OUTFIT AI BREAKDOWN
// ==================================================

app.post(
  "/api/wardrobe/analyze-outfit",
  async (req, res) => {
    try {
      const { imageBase64 } = req.body || {};
      const imageHash = crypto
  .createHash("sha256")
  .update(imageBase64 || "")
  .digest("hex");

console.log(
  `[WARDROBE OUTFIT] Image received | length=${imageBase64?.length || 0} | hash=${imageHash}`
);

      if (
        !imageBase64 ||
        typeof imageBase64 !== "string" ||
        imageBase64.trim().length === 0
      ) {
        return res.status(400).json({
          success: false,
          error: "No full outfit photo was provided.",
        });
      }

      if (!OPENAI_API_KEY) {
        return res.status(500).json({
          success: false,
          error: "OPENAI_API_KEY is not configured on the server.",
        });
      }

      let imageUrl = imageBase64.trim();

      if (!imageUrl.startsWith("data:image/")) {
        imageUrl = `data:image/jpeg;base64,${imageUrl}`;
      }

      const systemPrompt = `
You are VESTRA Vision, a professional fashion outfit breakdown system.

Analyze the COMPLETE OUTFIT visible in the supplied image.

Your job is to identify the distinct clothing pieces and accessories that
are visibly present.

Do NOT identify, name, or describe the person wearing the outfit.
Do NOT infer the person's gender, identity, body measurements, age, or other
personal characteristics.
Do NOT invent garments that are not visibly present.

==================================================
IMPORTANT OUTFIT RULES
==================================================

1. Break the outfit into distinct wardrobe pieces.
2. Include visible clothing and accessories.
3. If a dress or gown is visible, treat it as ONE piece rather than splitting
   it into a top and bottom.
4. If a jumpsuit is visible, treat it as ONE piece.
5. If a suit is clearly visible, identify its visible components separately
   when they are distinct garments, such as blazer and trousers.
6. Do not list the same physical garment twice.
7. Shoes should normally be one pair represented as one item.
8. For matching pairs such as earrings, list them as one accessory item.
9. Only include an item when there is reasonable visual evidence for it.
10. If a property cannot reasonably be determined, return "Unknown".
11. Do not describe the wearer.

==================================================
CATEGORIES
==================================================

Use one of these categories whenever possible:

Tops
Bottoms
Dresses
Skirts
Jumpsuits
Shoes
Outerwear
Accessories
Bags
Headwear
Activewear
Swimwear
Traditional Wear
Pet Clothing
Other

==================================================
OUTPUT
==================================================

Return ONLY valid JSON in this exact structure:

{
  "items": [
    {
      "name": "string",
      "category": "string",
      "color": "string",
      "style": "string",
      "fit": "string",
      "length": "string",
      "material": "string",
      "pattern": "string",
      "notes": "string"
    }
  ],
  "outfitSummary": "string"
}

The outfitSummary should briefly describe the overall clothing combination,
not the person.
`;

      const userPrompt = `
Analyze this complete outfit photo.

Identify every clearly visible wardrobe piece or accessory that could be
stored as an individual Vestra wardrobe item.

Be conservative: visible evidence is required. If something is ambiguous,
do not invent it.
`;

      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${OPENAI_API_KEY}`,
          },
          body: JSON.stringify({
            model: OPENAI_MODEL,
            messages: [
              {
                role: "system",
                content: [
                  {
                    type: "text",
                    text: systemPrompt,
                  },
                  {
                    type: "image_url",
                    image_url: {
                      url: imageUrl,
                    },
                  },
                ],
              },
              {
                role: "user",
                content: userPrompt,
              },
            ],
            temperature: 0.2,
            response_format: {
              type: "json_object",
            },
          }),
        }
      );

      const responseText = await response.text();

      let data;

      try {
        data = JSON.parse(responseText);
      } catch (_) {
        return res.status(502).json({
          success: false,
          error: "Vestra received an invalid response from the AI service.",
        });
      }

      if (!response.ok) {
        console.error(
          "Full outfit AI error:",
          JSON.stringify(data, null, 2)
        );

        return res.status(response.status).json({
          success: false,
          error:
            data?.error?.message ||
            "The AI service could not analyze the outfit.",
        });
      }

      const content =
        data?.choices?.[0]?.message?.content;

      if (!content) {
        return res.status(502).json({
          success: false,
          error: "The AI returned an empty outfit analysis.",
        });
      }

      let parsed;

      try {
        parsed = JSON.parse(content);
      } catch (_) {
        console.error(
          "Full outfit AI returned invalid JSON:",
          content
        );

        return res.status(502).json({
          success: false,
          error: "The AI returned an invalid outfit breakdown.",
        });
      }

      const rawItems = Array.isArray(parsed?.items)
        ? parsed.items
        : [];

      const items = rawItems
        .map((item) => ({
          name: cleanValue(item?.name, "Unknown item"),
          category: cleanValue(item?.category, "Other"),
          color: cleanValue(item?.color, "Unknown"),
          style: cleanValue(item?.style, "Unknown"),
          fit: cleanValue(item?.fit, "Unknown"),
          length: cleanValue(item?.length, "Unknown"),
          material: cleanValue(item?.material, "Unknown"),
          pattern: cleanValue(item?.pattern, "Unknown"),
          notes: cleanValue(item?.notes, ""),
        }))
        .filter((item) => item.name.trim().length > 0);

      return res.json({
        success: true,
        items,
        outfitSummary: cleanValue(
          parsed?.outfitSummary,
          "Vestra identified the visible pieces in this outfit."
        ),
      });
    } catch (error) {
      console.error(
        "Full outfit analysis error:",
        error
      );

      return res.status(
        error?.status || 500
      ).json({
        success: false,
        error:
          error?.message ||
          "Vestra could not analyze the full outfit.",
      });
    }
  }
);

// ==================================================
// UTILITY
// ==================================================

function cleanValue(
  value,
  fallback = ""
) {
  if (
    value === undefined ||
    value === null
  ) {
    return fallback;
  }

  const text =
    String(value).trim();

  return text.length > 0
    ? text
    : fallback;
}

function cleanStringArray(value) {
  if (Array.isArray(value)) {
    return value
      .map((item) =>
        String(item).trim()
      )
      .filter(Boolean);
  }

  if (
    typeof value === "string" &&
    value.trim().length > 0
  ) {
    return value
      .split(",")
      .map((item) =>
        item.trim()
      )
      .filter(Boolean);
  }

  return [];
}
// ============================================================
// TICKETMASTER EVENT DISCOVERY
// GLOBAL, CATEGORY-AWARE, FAILURE-TOLERANT EVENT SEARCH
// ============================================================

const EVENT_CATEGORY_CONFIG = {
  all: {
    classificationName: "",
    keywords: [],
    matchTerms: [],
  },

  music: {
    classificationName: "Music",
    keywords: [
      "music",
      "concert",
      "live music",
      "live",
      "DJ",
    ],
    matchTerms: [
      "music",
      "concert",
      "live music",
      "dj",
      "dance/electronic",
      "rock",
      "pop",
      "hip-hop",
      "hip hop",
      "jazz",
      "classical",
      "reggae",
      "afrobeat",
      "afrobeats",
      "r&b",
      "country",
      "festival",
    ],
  },

  fashion: {
    classificationName: "",
    keywords: [
      "fashion",
      "fashion week",
      "runway",
      "fashion show",
      "couture",
      "designer",
      "modeling",
      "modelling",
      "style",
    ],
    matchTerms: [
      "fashion",
      "fashion week",
      "runway",
      "fashion show",
      "couture",
      "designer",
      "modeling",
      "modelling",
      "style",
      "apparel",
      "clothing",
    ],
  },

  arts: {
    classificationName: "Arts & Theatre",
    keywords: [
      "theatre",
      "theater",
      "art",
      "exhibition",
      "gallery",
      "dance",
      "performance",
    ],
    matchTerms: [
      "arts",
      "art",
      "theatre",
      "theater",
      "exhibition",
      "gallery",
      "dance",
      "performance",
      "museum",
      "ballet",
      "opera",
    ],
  },

  sports: {
    classificationName: "Sports",
    keywords: [
      "sports",
      "football",
      "soccer",
      "basketball",
      "rugby",
      "tennis",
      "athletics",
      "boxing",
      "cricket",
      "golf",
      "volleyball",
      "motorsport",
    ],
    matchTerms: [
      "sports",
      "football",
      "soccer",
      "basketball",
      "rugby",
      "tennis",
      "athletics",
      "boxing",
      "cricket",
      "golf",
      "volleyball",
      "motorsport",
      "formula",
      "wrestling",
    ],
  },

  comedy: {
    classificationName: "Arts & Theatre",
    keywords: [
      "comedy",
      "stand up",
      "stand-up",
      "comedian",
    ],
    matchTerms: [
      "comedy",
      "stand up",
      "stand-up",
      "comedian",
      "humor",
      "humour",
    ],
  },

  festivals: {
    classificationName: "",
    keywords: [
      "festival",
      "fest",
      "carnival",
      "cultural festival",
    ],
    matchTerms: [
      "festival",
      "fest",
      "carnival",
      "cultural",
    ],
  },

  parties: {
    classificationName: "",
    keywords: [
      "party",
      "nightlife",
      "club",
      "DJ",
      "rave",
      "night party",
    ],
    matchTerms: [
      "party",
      "nightlife",
      "club",
      "dj",
      "rave",
      "night",
    ],
  },

  business: {
    classificationName: "",
    keywords: [
      "business conference",
      "conference",
      "networking",
      "expo",
      "summit",
      "business",
    ],
    matchTerms: [
      "business",
      "conference",
      "networking",
      "expo",
      "summit",
      "entrepreneur",
      "startup",
      "trade show",
    ],
  },

  food: {
    classificationName: "",
    keywords: [
      "food festival",
      "culinary",
      "food",
      "wine and food",
      "tasting",
      "restaurant",
    ],
    matchTerms: [
      "food",
      "culinary",
      "restaurant",
      "tasting",
      "wine",
      "dining",
      "chef",
      "cooking",
      "gastronomy",
    ],
  },

  family: {
    classificationName: "Family",
    keywords: [
      "family",
      "kids",
      "children",
      "family day",
    ],
    matchTerms: [
      "family",
      "kids",
      "children",
      "child",
      "family day",
    ],
  },
};

function normalizeEventCategory(value) {
  const category = String(value || "all")
    .trim()
    .toLowerCase();

  return Object.prototype.hasOwnProperty.call(
    EVENT_CATEGORY_CONFIG,
    category
  )
    ? category
    : "all";
}

function normalizeEventSearchText(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9&/+ -]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function eventMatchesCategory(event, category) {
  if (!category || category === "all") {
    return true;
  }

  const config = EVENT_CATEGORY_CONFIG[category];

  if (!config) {
    return true;
  }

  const classification = event?.classifications?.[0] || {};

  const segment = normalizeEventSearchText(
    classification?.segment?.name
  );

  const genre = normalizeEventSearchText(
    classification?.genre?.name
  );

  const subGenre = normalizeEventSearchText(
    classification?.subGenre?.name
  );

  const title = normalizeEventSearchText(
    event?.name
  );

  const description = normalizeEventSearchText(
    event?.description
  );

  const combined = [
    segment,
    genre,
    subGenre,
    title,
    description,
  ]
    .filter(Boolean)
    .join(" ");

  return config.matchTerms.some((term) => {
    const normalizedTerm = normalizeEventSearchText(term);

    if (!normalizedTerm) {
      return false;
    }

    return combined.includes(normalizedTerm);
  });
}

function getPreferredEventImage(event) {
  const images = Array.isArray(event?.images)
    ? event.images
    : [];

  return (
    images.find(
      (image) =>
        Number(image?.width || 0) >= 500 &&
        Number(image?.height || 0) >= 300
    )?.url ||
    images.find((image) => image?.url)?.url ||
    ""
  );
}

function normalizeTicketmasterEvent(event, fallbackCity = "") {
  const venue =
    event?._embedded?.venues?.[0] || {};

  const classification =
    event?.classifications?.[0] || {};

  const latitude =
    venue?.location?.latitude ??
    null;

  const longitude =
    venue?.location?.longitude ??
    null;

  const locationParts = [
    venue?.address?.line1,
    venue?.address?.line2,
    venue?.city?.name,
    venue?.state?.name,
    venue?.country?.name,
  ].filter(Boolean);

  return {
    id: event?.id || "",
    title: event?.name || "Untitled Event",

    date:
      event?.dates?.start?.localDate ||
      "",

    time:
      event?.dates?.start?.localTime ||
      "",

    venue:
      venue?.name ||
      "",

    city:
      venue?.city?.name ||
      fallbackCity ||
      "",

    country:
      venue?.country?.name ||
      "",

    countryCode:
      venue?.country?.countryCode ||
      "",

    location:
      locationParts.join(", "),

    latitude:
      latitude === null ||
      latitude === undefined
        ? null
        : Number(latitude),

    longitude:
      longitude === null ||
      longitude === undefined
        ? null
        : Number(longitude),

    image:
      getPreferredEventImage(event),

    url:
      event?.url ||
      "",

    category:
      classification?.segment?.name ||
      "",

    genre:
      classification?.genre?.name ||
      "",

    subGenre:
      classification?.subGenre?.name ||
      "",

    source: "ticketmaster",

    sourceId:
      event?.id ||
      "",
  };
}

async function fetchTicketmasterEvents({
  city = "",
  countryCode = "",
  keyword = "",
  classificationName = "",
  latitude = null,
  longitude = null,
  radius = "",
  startDateTime = "",
  endDateTime = "",
  size = 20,
}) {
  if (!TICKETMASTER_API_KEY) {
    const error = new Error(
      "Ticketmaster API key is not configured on the server."
    );

    error.code = "TICKETMASTER_KEY_MISSING";

    throw error;
  }

  const params = new URLSearchParams();

  params.set(
    "apikey",
    TICKETMASTER_API_KEY
  );

  params.set(
    "size",
    String(
      Math.min(
        Math.max(
          Number(size) || 20,
          1
        ),
        50
      )
    )
  );

  params.set(
    "sort",
    "date,asc"
  );

  if (city) {
    params.set(
      "city",
      city
    );
  }

  if (countryCode) {
    params.set(
      "countryCode",
      countryCode
    );
  }

  if (keyword) {
    params.set(
      "keyword",
      keyword
    );
  }

  if (classificationName) {
    params.set(
      "classificationName",
      classificationName
    );
  }

  if (
    Number.isFinite(latitude) &&
    Number.isFinite(longitude)
  ) {
    params.set(
      "latlong",
      `${latitude},${longitude}`
    );

    if (radius) {
      params.set(
        "radius",
        String(radius)
      );

      params.set(
        "unit",
        "km"
      );
    }
  }

  // IMPORTANT:
  // We only send date filters when the client explicitly provides them.
  // We do NOT inject the current timestamp automatically.
  if (startDateTime) {
    params.set(
      "startDateTime",
      startDateTime
    );
  }

  if (endDateTime) {
    params.set(
      "endDateTime",
      endDateTime
    );
  }

  const ticketmasterUrl =
    `https://app.ticketmaster.com/discovery/v2/events.json?${params.toString()}`;

  const controller =
    new AbortController();

  const timeout =
    setTimeout(
      () => controller.abort(),
      12000
    );

  let response;

  try {
    response = await fetch(
      ticketmasterUrl,
      {
        signal:
          controller.signal,
      }
    );
  } catch (error) {
    const timeoutError =
      new Error(
        error?.name === "AbortError"
          ? "Ticketmaster request timed out."
          : `Ticketmaster connection failed: ${error?.message || "Unknown network error."}`
      );

    timeoutError.code =
      error?.name === "AbortError"
        ? "TICKETMASTER_TIMEOUT"
        : "TICKETMASTER_NETWORK_ERROR";

    timeoutError.cause =
      error;

    throw timeoutError;
  } finally {
    clearTimeout(timeout);
  }

  const rawText =
    await response.text();

  let data = {};

  try {
    data =
      rawText
        ? JSON.parse(rawText)
        : {};
  } catch (_) {
    data = {};
  }

  if (!response.ok) {
    const providerMessage =
      data?.fault?.faultstring ||
      data?.fault?.detail?.errorcode ||
      data?.message ||
      `Ticketmaster returned HTTP ${response.status}.`;

    const error =
      new Error(
        providerMessage
      );

    error.status =
      response.status;

    error.code =
      "TICKETMASTER_HTTP_ERROR";

    error.providerMessage =
      providerMessage;

    throw error;
  }

  const events =
    Array.isArray(
      data?._embedded?.events
    )
      ? data._embedded.events
      : [];

  return {
    events,
    total:
      Number(
        data?.page?.totalElements ||
        events.length
      ),
  };
}

function buildEventProviderQueries({
  category,
  keyword,
  city,
  countryCode,
  latitude,
  longitude,
  radius,
  startDateTime,
  endDateTime,
  size,
}) {
  const config =
    EVENT_CATEGORY_CONFIG[
      category
    ] || EVENT_CATEGORY_CONFIG.all;

  const base = {
    city,
    countryCode,
    latitude,
    longitude,
    radius,
    startDateTime,
    endDateTime,
    size,
  };

  const queries = [];

  // Explicit keyword searches are the strongest user intent.
  if (keyword) {
    queries.push({
      ...base,
      keyword,
      classificationName:
        category !== "all"
          ? config.classificationName
          : "",
      strategy: "keyword",
    });

    return queries;
  }

  // "All" needs only one broad provider call.
  if (category === "all") {
    queries.push({
      ...base,
      keyword: "",
      classificationName: "",
      strategy: "broad",
    });

    return queries;
  }

  // First try the provider's own classification where one exists.
  if (config.classificationName) {
    queries.push({
      ...base,
      keyword: "",
      classificationName:
        config.classificationName,
      strategy: "classification",
    });
  }

  // Then try one representative category keyword.
  // We deliberately keep this bounded so one search cannot create
  // a large number of provider calls.
  if (config.keywords.length > 0) {
    queries.push({
      ...base,
      keyword: config.keywords[0],
      classificationName: "",
      strategy: "category-keyword",
    });
  }

  // A broad fallback is added only if the first category searches
  // return no usable results. It is not executed unnecessarily.
  queries.push({
    ...base,
    keyword: "",
    classificationName: "",
    strategy: "broad-fallback",
  });

  return queries;
}

function dedupeEvents(events) {
  const map =
    new Map();

  for (const event of events) {
    const key =
      event?.id ||
      [
        event?.title,
        event?.date,
        event?.venue,
        event?.city,
      ]
        .map((value) =>
          String(value || "")
            .trim()
            .toLowerCase()
        )
        .join("|");

    if (!key) {
      continue;
    }

    if (!map.has(key)) {
      map.set(
        key,
        event
      );
    }
  }

  return Array.from(
    map.values()
  );
}

function sortEventsByDate(events) {
  return [...events].sort(
    (a, b) => {
      const aValue =
        `${a?.date || "9999-12-31"}T${a?.time || "23:59:59"}`;

      const bValue =
        `${b?.date || "9999-12-31"}T${b?.time || "23:59:59"}`;

      return (
        new Date(aValue) -
        new Date(bValue)
      );
    }
  );
}

app.get(
  "/api/events/discover",
  async (req, res) => {
    const city =
      String(
        req.query.city || ""
      ).trim();

    const countryCode =
      String(
        req.query.countryCode || ""
      )
        .trim()
        .toUpperCase();

    const keyword =
      String(
        req.query.keyword || ""
      ).trim();

    const category =
      normalizeEventCategory(
        req.query.category
      );

    const latitudeRaw =
      String(
        req.query.latitude || ""
      ).trim();

    const longitudeRaw =
      String(
        req.query.longitude || ""
      ).trim();

    const latitude =
      latitudeRaw
        ? Number(latitudeRaw)
        : null;

    const longitude =
      longitudeRaw
        ? Number(longitudeRaw)
        : null;

    const radius =
      String(
        req.query.radius || ""
      ).trim();

    const startDateTime =
      String(
        req.query.startDateTime || ""
      ).trim();

    const endDateTime =
      String(
        req.query.endDateTime || ""
      ).trim();

    const requestedSize =
      Number(
        req.query.size || 20
      );

    const size =
      Math.min(
        Math.max(
          Number.isFinite(
            requestedSize
          )
            ? Math.floor(
                requestedSize
              )
            : 20,
          1
        ),
        50
      );

    try {
      if (!TICKETMASTER_API_KEY) {
        return res.status(500).json({
          success: false,
          error:
            "Ticketmaster API key is not configured.",
        });
      }

      const providerQueries =
        buildEventProviderQueries({
          category,
          keyword,
          city,
          countryCode,
          latitude,
          longitude,
          radius,
          startDateTime,
          endDateTime,
          size,
        });

      const collectedEvents =
        [];

      const providerFailures =
        [];

      let successfulProviderQueries =
        0;

      // ------------------------------------------------
      // CATEGORY DISCOVERY
      // ------------------------------------------------
      //
      // Run the first category strategies in order.
      // If they find events, we stop before making the
      // broad fallback request.
      // ------------------------------------------------

      for (
        let index = 0;
        index < providerQueries.length;
        index += 1
      ) {
        const query =
          providerQueries[index];

        // Broad fallback should only run when we still
        // have no category matches.
        if (
          query.strategy ===
            "broad-fallback" &&
          collectedEvents.length > 0
        ) {
          break;
        }

        try {
          const result =
            await fetchTicketmasterEvents(
              query
            );

          successfulProviderQueries +=
            1;

          let usableEvents =
            result.events;

          // When this is a category search, category
          // fallback results must actually belong to
          // that category.
          if (
            category !== "all"
          ) {
            usableEvents =
              usableEvents.filter(
                (event) =>
                  eventMatchesCategory(
                    event,
                    category
                  )
              );
          }

          collectedEvents.push(
            ...usableEvents
          );
        } catch (providerError) {
          providerFailures.push({
            strategy:
              query.strategy,
            message:
              providerError?.message ||
              "Ticketmaster request failed.",
            code:
              providerError?.code ||
              "",
            status:
              providerError?.status ||
              null,
          });

          // Continue to the next strategy.
          // A single Ticketmaster failure must not
          // break the entire Vestra backend.
          continue;
        }
      }

      const normalizedEvents =
        sortEventsByDate(
          dedupeEvents(
            collectedEvents.map(
              (event) =>
                normalizeTicketmasterEvent(
                  event,
                  city
                )
            )
          )
        ).slice(0, size);

      // If every provider attempt failed, return a
      // controlled response instead of throwing an
      // unhandled backend error.
      if (
        successfulProviderQueries ===
          0 &&
        providerFailures.length > 0
      ) {
        return res.status(200).json({
          success: true,
          provider:
            "ticketmaster",
          category,
          location: {
            city:
              city || null,
            countryCode:
              countryCode || null,
            latitude,
            longitude,
            radiusKm:
              radius
                ? Number(radius)
                : null,
            scope:
              city ||
              countryCode
                ? "location"
                : "global",
          },
          total: 0,
          events: [],
          providerQueries:
            providerQueries.length,
          providerFailures,
          message:
            "Event discovery is temporarily unavailable. Please try again.",
        });
      }

      return res.json({
        success: true,
        provider:
          "ticketmaster",
        category,
        location: {
          city:
            city || null,
          countryCode:
            countryCode || null,
          latitude,
          longitude,
          radiusKm:
            radius
              ? Number(radius)
              : null,
          scope:
            city ||
            countryCode
              ? "location"
              : "global",
        },
        total:
          normalizedEvents.length,
        events:
          normalizedEvents,
        providerQueries:
          providerQueries.length,
        providerFailures,
      });
    } catch (error) {
      // Final safety boundary for the event subsystem.
      // The rest of the Vestra server remains alive.
      console.error(
        "Ticketmaster discovery error:",
        error
      );

      return res.status(200).json({
        success: true,
        provider:
          "ticketmaster",
        category,
        location: {
          city:
            city || null,
          countryCode:
            countryCode || null,
          latitude,
          longitude,
          radiusKm:
            radius
              ? Number(radius)
              : null,
          scope:
            city ||
            countryCode
              ? "location"
              : "global",
        },
        total: 0,
        events: [],
        providerQueries: 0,
        providerFailures: [
          {
            strategy:
              "server",
            message:
              error?.message ||
              "Unable to discover events right now.",
            code:
              error?.code ||
              "",
          },
        ],
        message:
          "Event discovery is temporarily unavailable. The rest of Vestra remains available.",
      });
    }
  }
);


// ==================================================
// START SERVER
// ==================================================

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      "-----------------------------------------"
    );

    console.log(
      `Vestra Backend running on port ${PORT}`
    );

    console.log(
      `OpenAI configured: ${Boolean(
        OPENAI_API_KEY
      )}`
    );

    console.log(
      `Ticketmaster configured: ${Boolean(
        TICKETMASTER_API_KEY
      )}`
    );

    console.log(
      `Supabase configured: ${Boolean(
        supabaseAdmin
      )}`
    );

    console.log(
      "-----------------------------------------"
    );
  }
);