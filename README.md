# Coin Fountain Sweeper – Game Design Document

## 1. Game Overview
**High Concept:** The player manages an overflowing wishing fountain by clicking on falling coins to remove them before they pile too high. Coins (as **RigidBody2D** physics objects) fall into the fountain chaotically, and the player must prioritize which coins to click under pressure. 

**Player Fantasy:** You are the guardian of the wishing fountain, frantically keeping the waterline clear of coins. Every click gives satisfying feedback – coins pop and sparkle as you scoop them away – making you feel powerful and in control of chaos.

**Core Loop (Moment-to-Moment):** 
- Coins of various types continuously spawn above the fountain and fall in via physics (leveraging Godot’s RigidBody2D with adjustable **mass, friction, bounce**【48†L310-L318】). 
- The player clicks on coins to collect/remove them. Each removal yields immediate visual and audio feedback. 
- Different coin types behave uniquely (heavy coins pin others, bouncy coins chaotically ricochet), requiring the player to triage which coins to click first. 
- If the coin stack stays above the waterline too long, a loss warning (e.g. water bubbling) triggers; sustained overflow ends the game. 
- Between waves (or on milestones), a “wish” power-up may trigger, momentarily altering spawn rates or physics to spice up play. 

This loop emphasizes **real-time micromanagement**: constantly clicking, juggling priorities, and reacting to physics chaos, fulfilling the theme by forcing continuous small-scale control and decision-making.  

## 2. Core Game Loop Breakdown
- **Step 1:** Coins spawn at varying horizontal positions above the fountain, with increasing frequency over time. Spawn logic uses a simple timer: for instance, start at 1 coin/sec and gradually decrease interval (e.g. `spawn_interval = max(0.2, 1.0 - 0.1 * minutes_passed)`).  
- **Step 2:** Spawned coins enter the fountain as RigidBody2D bodies. Gravity pulls them down; collisions and physics cause them to stack or bounce off each other (leveraging Godot’s physics engine for realism【48†L310-L318】). 
- **Step 3:** The player uses the mouse to click coins. Clicking instantly removes a coin (or perhaps “vacuum” it out) with an animated effect. This clears space and increments score. 
- **Step 4:** After each click, visual (sprite animation or particles) and audio (pop sound) feedback plays, reinforcing the action (improving game feel). 
- **Step 5:** The player must manage the pile: if the highest coin stays above a visible waterline for a set duration, the fountain “boils over” and game over occurs. A warning (e.g. water rumble effect) appears shortly before to increase tension.  
- **Step 6:** Occasionally, a **Wish** event triggers (see section 7) giving a temporary modifier like slow-motion or coin magnet, then returns to normal. 

**Decision Pressure:** The player constantly chooses which coins to remove first. Heavy coins might pin others, bouncy coins may jump over the waterline unpredictably, forcing quick decisions under pressure. This creates satisfying **twitch + strategic** tension, rewarding sharp eyes and reflexes.

## 3. Evaluation Strategy
To maximize judging criteria:

- **Theme (Micromanagement):** Every element reinforces micro-level control. Rapid coin clicking and juggling stack height directly implements micromanagement. The constantly rising spawn rate ensures the player is always "managing tiny tasks under pressure". The design ties the theme to core gameplay by making the fountain a **hands-on, moment-to-moment management task**. 

- **Special Object (Coins):** Coins are central visually and mechanically. Multiple coin types (normal, heavy, bouncy) each use physics properties (mass, friction, bounce) to create different player challenges【48†L310-L318】. We highlight coins with contrasting sprites and effects, and ensure each coin reaction (bounce, ping) is satisfyingly animated. Because coins constantly enter play, they remain ever-present “special objects” tied to theme (wishes).  

- **Visuals (Clarity + Juice):** We use high-contrast coin sprites against a semi-transparent fountain water background so they stand out (improves readability, as clicker games recommend【50†L165-L172】). The waterline threshold is clearly marked. Visual "juice" includes **screen shake** on big impacts (e.g. when a heavy coin lands) to add dynamism【38†L24-L30】【56†L274-L279】, plus coin-specific VFX (sparks or splash particles on click or bounce). The UI is kept minimal: just score and waterline indicator, avoiding clutter (a clean UI retains players【50†L225-L232】). 

- **Audio (Feedback + Layering):** Layered SFX enrich click interactions. Each coin type has a distinct sound: a satisfying *plink* for normal coins, heavy *thud* for heavy coins, and *twang* for bouncy coins. These overlap softly (using separate audio buses) so rapid clicks don’t cacophony. Background ambient music or fountain sounds play underneath. Every click plays a “pop” and maybe a randomized chirp to avoid repetition. Milestones (e.g. hitting 100 coins) trigger a short jingle. This layered audio feedback makes interactions feel more impactful【52†L274-L279】【56†L281-L288】. 

- **Gameplay (Depth vs Simplicity):** The core mechanics are simple (spawn coins, click to remove), but emergent chaos and prioritization adds depth. Physics interactions (coins pinning or bouncing) keep the experience dynamic without adding new buttons or complex rules. The Wish system adds variety without deep new mechanics (see below). Difficulty scales only by increasing spawn rate or chaos, keeping system complexity low. This balance ensures the game is easy to pick up but hard to master, which appeals to jam judges looking for both accessibility and interesting challenge.

- **Polish (Game Feel, Feedback):** High emphasis on feedback. As one source notes, “clicking on a static sprite isn’t exciting, but clicking on a sprite that jumps or shakes is”【56†L274-L279】. We employ coin animations (like a quick squash/stretch on click), screen/UI shakes for big events, and particle splashes, so every player action feels lively. Time is budgeted for these visual flourishes: quick particles on coin removal, coin piling animations, and responsive UI (score pop-ups). The resulting “juice” (tiny animations, shakes, sounds) turns a simple mechanic into a polished, engaging feel.

## 4. Mechanics & Systems

- **Controls (Mouse-based):** The player uses the mouse to click coins (no drag or keyboard). Coins detect clicks via either `input_event` on their RigidBody2D or a RayCast from the mouse. On click, the coin’s script instantly removes it (and increments score). Cursor changes (like a sparkle) on hover could further polish (Tier 4).  

- **Coin Physics Behavior:** All coins are **RigidBody2D** (dynamic physics). Each coin has a **PhysicsMaterial2D** to set friction and bounce. For example, normal coins have moderate friction and bounce; heavy coins have high mass and low bounce; bouncy coins have low mass but high bounce (up to 0.8–1.0【48†L310-L318】). This ensures heavy coins barely bounce and can pin others, while bouncy ones ricochet around chaotically. We rely on Godot’s default gravity and these physics settings to create emergent stacks and collisions【48†L310-L318】.  

- **Spawn Logic:** Coins spawn from off-screen above the fountain at random X positions. A Timer controls spawn intervals. **Tier 1:** Basic: `spawn_interval = 1.0` second initially, then every minute `spawn_interval = max(0.2, spawn_interval - 0.1)`. This simple linear decrease increases pressure over time. Spawn position can alternate to cover screen. Coin type chances can slightly vary (e.g. heavy coin 10% probability early, increasing later). The goal is to ramp chaos, not complexity.  

- **Fail-State (Waterline & Warning):** A visible waterline marks the threshold. We track the highest coin’s Y position each physics step. If any coin stays above the line for >2 seconds, trigger loss. However, before losing, a warning event (e.g. water bubbling or UI flash) appears to signal imminent fail (Tier 2). This gives the player a short chance to click down the pile. A scoreboard and restart button appear on game over.

- **Decision-Making Pressure:** The combination of rising spawn rate and physics unpredictability forces real-time prioritization. For example, clicking a heavy coin (Tier 2 feature) might prevent it from causing a pin, but a bouncy coin near threshold could be a bigger immediate threat. These core rules generate the micro-management gameplay.

## 5. Entities (Coins)
Design 3+ coin types with distinct physics and roles:

- **Normal Coin (Tier 1):** 
  - *Role:* The basic target. Moderate mass (e.g. mass=1) and bounce (~0.3). 
  - *Physics:* Friction ≈ 0.5, bounce ≈ 0.3【48†L310-L318】. Falls and bounces a bit off walls or other coins.
  - *Strategy:* Easy to remove; stacking risk is moderate. Player typically clicks these for steady score. 

- **Heavy Coin (Tier 2):** 
  - *Role:* Big threat coin. High mass (e.g. mass=3× normal) and near-zero bounce. 
  - *Physics:* Friction higher, bounce=0. Low restitution means it slams into stack and pins coins. It may even break small stacks (like a wrecking ball). 
  - *Strategy:* Needs quick removal to prevent it from crushing others. Clicking it yields a bigger sound/thud SFX and maybe more score (to offset risk). It’s visually larger or darker to signify weight.

- **Bouncy Coin (Tier 2):** 
  - *Role:* Chaotic element. Low mass (e.g. mass=0.5) but very high bounce (~0.9). 
  - *Physics:* Bouncy material (bounce ~0.9【48†L310-L318】), low friction so it slides. It jumps around unpredictably, sometimes clearing waterline unpredictably. 
  - *Strategy:* Hard to predict path; player may let them bounce and clear on their own, or click quickly if threatening overflow. Clicking triggers a bright "sparkle" particle effect. They score normal points but provide audio cue of “boing” to alert player of danger.

- **(Optional Tier 3) Magnet Coin:** (If time permits) A coin that, when near other coins, slightly attracts them (simulate magnetism). This could cluster coins oddly. Implementation: have it apply a small impulse toward nearby coins using `apply_force()`. Adds a twist to stacking.

Each coin’s physics material is adjustable via the Godot editor (PhysicsMaterial2D properties bounce/friction【48†L310-L318】). The variety forces the player to adapt strategies (e.g. heavy coins are early kills, bouncy coins are sometimes left to bounce down).

## 6. Progression & Difficulty
- **Scaling:** Difficulty rises over time by **spawn rate increase** (as described). Instead of adding new mechanics, we simply make coins fall faster and more frequently (not more complex mechanics). For example, after each minute, reduce `spawn_interval` by 0.1s, or use an exponential factor like `interval = initial * 0.95^minutes`.  
- **Chaos Growth:** Over time, coin interactions naturally become chaotic due to stacking. We may gradually increase the ratio of heavy/bouncy coins or introduce short spawn bursts (two coins at once occasionally) as Tier 3.  
- **Pressure Curve:** Early game: slow spawn, mostly normal coins (Tier 1). Mid game: spawn rate moderate, occasional heavy/bouncy (Tier 2), and first Wish events trigger (Tier 2). Late game: very fast spawn, mixed coin types, frequent Wish events to break monotony (Tier 2). The goal is that the player feels steadily rising stress without any sudden spikes that aren't foreshadowed. The waterline warning provides tension cues as fail approaches.

## 7. Wish System (Twist)
A simple “Wish” mechanic adds variety:

- **Trigger Logic (Tier 2):** The system occasionally triggers (e.g. every 15–30 seconds, or after every 20 coins collected, 50% chance). When triggered, a random Wish effect is chosen and announced (a short message/icon appears). The effect lasts a short fixed time (5–10 seconds). This randomness spices up the core loop. 

- **Example Effects (Tier 2):** 
  1. **Slow Motion:** Temporarily halve physics speed (or multiply all velocities by 0.5). Makes clicking easier but also spawns may pause or slow. (Implementation: adjust `Engine.time_scale` or RigidBody scale.)
  2. **Coin Magnet:** An Area2D around the mouse cursor that attracts nearby coins (apply a small force towards cursor). This helps clear coins quickly but spawns may speed up for balance. (Simple: iterate coins in radius, use `apply_force()`.)
  3. **Double Spawn:** For the duration, coins spawn twice as fast (risk: core loop goes chaotic). (Implementation: reduce spawn interval by 50%.)
  4. **Auto-Collector:** A brief auto-click: each coin the player clicks auto-collects nearest neighbor too. (Requires bookkeeping of last click; Tier 4.)
  5. **Coin Rush:** Many coins fall in a stream (like a mini wave), giving high risk/high reward. 

Each Wish is chosen to be easy to code (e.g. adjusting timers or using Area2D) but high-impact on gameplay variety. Tier them as **Tier 2** as they significantly affect gameplay but are not core.  The random Wish events encourage quick adaptation and break monotony.

## 8. Juice & Game Feel
(This section has high priority for polish.)

- **Screen/Camera Shake:** We use a simple trauma-based camera shake on big collisions (e.g. heavy coin impact)【38†L24-L30】. This “dynamic feel” adds appeal by making heavy events feel weighty. The recipe: a `Camera2D` script with a `trauma` parameter that adds random jitter when coins collide dramatically【38†L24-L30】. Shake is additive and decays quickly (0.2–0.5s) to avoid nausea.

- **Sprite Animations:** Each coin has a slight bounce/stretch animation on spawn or click (micro-animation). On click, coins may briefly scale up/down or spin and fade (a common clicker game effect【50†L184-L190】). This visual reaction makes the coin feel responsive. 

- **Particles:** On coin removal, emit a small burst of particles at the coin’s position (e.g. golden sparkles or splash puffs). On heavy coin hits, splashes or crack particles on the pile. These should be short-lived (like 0.5s) and small to avoid clutter. The clicker guide suggests even tiny particle bursts (crumbs when cookie clicked) greatly enhance satisfaction【52†L278-L287】.

- **Screen/Tap Feedback:** For each click, play a short “click” sound and maybe a quick UI flash (the score text could briefly glow). The particle and audio should align precisely on click. If water is near overflow, the camera could gently sway or tint red (visual alert) to push urgency.

- **UI Elements:** The UI (score, waterline) is minimal. Score counter at top-left, waterline indicator overlay on fountain sprite, maybe a simple progress bar/time to next spawn. UI elements use clean, legible fonts (avoiding clutter) – clicker advice stresses that complex UI leads players to quit【50†L225-L232】. 

- **Audio Layering:** Each click produces a layered SFX: e.g. a base “pop” plus a random chime from a small set to add variety【52†L278-L287】. Heavy coins play a deeper *thud*, bouncy coins a higher *tink*. We also add subtle ambient water and fountain sound on a separate audio bus. Feedback layering ensures the click sound always cuts through (the guide suggests ducking background SFX when playing click SFX【56†L281-L288】). 

All these effects combine: clicking makes coins *bounce, shimmer, spark*, and *chime*, delivering a satisfying game feel. As one source notes: “Game feel is vital... clicking on a static sprite isn’t exciting... clicking on a sprite that jumps or shakes is”【56†L281-L288】. We follow this principle in every click.

## 9. MVP Asset List
*(Strict minimal scope for jam readiness)*

- **Sprites:** 
  - Coin (base image; variants for heavy/bouncy colored differently)【40†L165-L172】.
  - Fountain/water background with marked waterline.
  - Simple UI elements: score text, warning icon.
  - Cursor or click effect sprite.
- **UI:** 
  - Score counter (font + background).
  - Game Over screen (text, restart button).
  - Optional Wish notification icon.
- **Particles:** 
  - Coin pop effect (glitter burst, maybe from Godot’s built-in Particle2D).
  - Splash/gold dust on heavy coin impact.
- **Sound Effects:** 
  - Coin click/pop, heavy thud, bounce ting.
  - Water bubbling (warning), win/chime sound.
  - Short background music loop or fountain ambient (looping).
- **Animation:** 
  - Coin click bounce (implemented via tween or animation).
  - Possibly a particle animation (simple, can use engine’s baked shapes).
- **Scenes:** 
  - Main scene (2D root + Camera2D).
  - Coin scene (RigidBody2D with Sprite & CollisionShape & script).

No advanced art or hundreds of sounds – a few polished pieces suffice for jam.

## 10. Godot Architecture

- **Main Scene Node Tree:** 
  - `Main (Node2D)`
    - `Camera2D` (for screen shake control).
    - `CoinSpawner (Node)`: handles timers and instancing coins.
    - `UI (CanvasLayer)`:
      - `ScoreLabel`
      - `WaterlineIndicator`
      - `WarningPopup` (maybe Control node for overflow warning).
      - `WishNotification`
    - `GameOverScreen (CanvasLayer)` (initially hidden).
    - `Background (Sprite2D or TextureRect)`
  
- **Coin Scene Node Tree:** 
  - `Coin (RigidBody2D)`【54†L327-L330】 (root of scene).
    - `Sprite2D` (coin graphic).
    - `CollisionShape2D` (circle).
    - (Optional) `Area2D Magnet` (if magnet effect coin). 
    - Attached script: handles `_on_input_event` or `_unhandled_input` to detect clicks and queue_free. Also implements any type-specific logic (heavy/bouncy flags).
  
- **Key Scripts & Responsibilities:** 
  - `GameManager.gd`: Tracks score, waterline height, fail-state timer, and triggers game over. Listens for coin removal to update score.
  - `Spawner.gd`: Controls spawn timing (`Timer`) and coin type randomization. Increases difficulty over time.
  - `Coin.gd`: On click, informs GameManager (increments score), plays effect, and removes itself. Might also call GameManager to add camera trauma (shake).
  - `WishSystem.gd`: Decides when to trigger wishes, selects effects, and applies modifiers. Listens for time or score events.
  - `CameraShake.gd`: Attached to Camera2D, implements the trauma decay and random offset (per recipe【38†L24-L30】). Has `add_trauma(amount)` called by heavy collisions or button events.
  
- **Signals & Interactions:** 
  - `Coin.clicked()` (custom signal when a coin is removed).
  - GameManager connects to coins on spawn to listen for click and collision events.
  - `GameManager.waterline_warning()` triggers visual alert.
  - `WishSystem.wish_triggered()` notifies UI to display effect name.
  - Use built-in signals like `timeout` on Timer, and possibly Area2D signals for magnet effect.

Node/script responsibilities are small and focused to keep code simple (no complex inheritance). 

## 11. Core Code Structure (High-Level)

- **Spawning System (Pseudocode):**  
  ```gdscript
  var spawn_timer = 1.0
  func _ready():
      start_timer(spawn_timer)
  func _on_Timer_timeout():
      spawn_coin()  # random position, random type
      # Decrease timer every minute
      if seconds_passed % 60 == 0:
          spawn_timer = max(0.2, spawn_timer - 0.1)
          reset_timer(spawn_timer)
  ```
- **Coin Click Detection:**  
  ```gdscript
  func _input_event(viewport, event, shape):
      if event is InputEventMouseButton and event.pressed:
          GameManager.coin_removed(self)
          # Spawn particle, sound
          queue_free()
  ```
- **Fail Condition (in GameManager):**  
  ```gdscript
  func _physics_process(delta):
      var highestY = get_highest_coin_y()
      if highestY < waterline_y:
          overflow_time += delta
          if overflow_time > 2.0:
              game_over()
      else:
          overflow_time = 0
  ```
- **Wish System:**  
  ```gdscript
  func check_wish_trigger():
      if randf() < 0.01:  # e.g. 1% chance each second
          trigger_random_wish()
  func trigger_random_wish():
      var effect = randi() % 3
      match effect:
          0: start_slow_motion()
          1: start_coin_magnet()
          2: increase_spawn_rate()
  ```
  Each effect has a simple implementation (e.g. `Engine.time_scale = 0.5` for slow motion, or instantiate an `Area2D` magnet at mouse).

All code relies on Godot 4 GDScript. It remains straightforward – avoid heavy object pooling or complex data structures to save time.

## 12. Development Schedule (7 Days, ~3–5 hrs/day)
*(Includes buffer as recommended【45†L244-L252】)*

- **Day 1 (Planning & Core Prototype):** (~4h) Sketch design, set up project and scenes. Implement basic coin spawn and click removal (Tier 1 core loop). Verify physics stacking. Plan code structure.  
- **Day 2 (Physics & Core Loop):** (~4h) Add coin types with different mass/bounce (Tier 2). Implement waterline logic and game over. Establish fail-state warning UI. Ensure core gameplay runs (no Wish yet).  
- **Day 3 (UI & Feedback):** (~4h) Build UI: score display, waterline marker, GameOver screen (Tier 1). Add basic sound on click and particle on coin removal (Tier 3). Add Camera2D with screen shake on heavy coin impact (Tier 3).  
- **Day 4 (Wish System & Progression):** (~4h) Add Wish triggers and example effects (slow motion, spawn boost) (Tier 2). Increase spawn rate over time. Playtest loop adjustments.  
- **Day 5 (Polish & Additional Juice):** (~4h) Refine visuals (coin animations, UI polish) and audio layers (distinct SFX). Add minor enhancements: maybe background music, sparkle on coin click. Fine-tune difficulty scaling.  
- **Day 6 (Buffer – Bugfixes & Extras):** (~3h) Use buffer time for any needed fixes. Implement any Tier 3 features if time (e.g. magnet coin). Ensure performance is smooth. Polish UI and feel.  
- **Day 7 (Final QA & Submission):** (~3h) Final playtesting, balance, ensure everything works. Add final touches (mute button, final credits). Prepare build for submission.

This plan leaves ~20% of time unallocated to handle unexpected tasks【45†L244-L252】. The goal is a playable core by mid-week, then polish. 

**Priority Focus:** Ensure a minimal but complete playable prototype by day 3–4, then layer polish. We emphasize quick, iterative testing over over-engineering. Time-saving tips: reuse Godot UI nodes, use existing free coin sprite assets if allowed, and leverage Godot’s built-in physics/materials (no custom physics code). With this scope and schedule, a polished jam entry is realistic in ~30 hours total【45†L244-L252】【48†L310-L318】.

**Sources:** Godot physics documentation and tutorials【48†L310-L318】【54†L327-L330】 inform coin behaviors; screen-shake and clicker design sources guide visual/audio polish【38†L24-L30】【56†L274-L279】.