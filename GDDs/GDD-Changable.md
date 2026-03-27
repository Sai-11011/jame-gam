# Coin Fountain Sweeper – Updated Game Design Document

## 1. Game Overview
**High Concept:** Manage a magical fountain by clearing coins before the water overflows. Coins (Bronze, Silver, Gold) fall in via physics; the player clicks them to “collect” them, causing them to burst and add to score (Favor). The fountain water level rises with each coin; keep it below the glowing Laser Line or lose.

**Player Fantasy:** Feel like a vigilant fountain keeper under pressure. Every click removes a coin with satisfying VFX/SFX and lowers the water level, while strategic “wishes” (lifelines) from a menu offer occasional relief. You experience power and risk–reward tension as you juggle cleanup and when to spend your earned Favor.

**Core Loop (Moment-to-Moment):** 
1. Coins spawn above the fountain (phase-adjusted mix of Bronze, Silver, Gold). They fall as `RigidBody2D` objects, bouncing off fountain walls (the custom Snake U-shape uses precise CollisionPolygon2D for realistic slopes)【54†L327-L330】.
2. **Water Level Mechanic:** Each coin has a `water_increase` amount. When a coin enters the water area, the water height is *smoothly raised* by that amount (using a `lerp()` Tween). Clicking a coin removes it and *reduces* the water by the coin’s value (like a mini pump). 
3. The player clicks coins (with mouse or touch) to remove them. Successful clicks instantly pop the coin, emit particle effects, and add Favor (score). The fountain water lowers accordingly.
4. If the water surface ever reaches the fixed Y=250 Laser Line, **Game Over** triggers immediately.
5. Meanwhile, the player accumulates Favor. In the Pause/Wish menu, they can spend Favor on powerful lifelines (the Wish Shop) for strategic advantages.
6. Gameplay intensifies through **Phased Progression**: early levels are easy (only Bronze coins), then Silver and Gold coins are introduced, and spawn rates increase, forcing quicker reactions and use of lifelines.

This loop ties directly to micromanagement: the player is constantly clicking to balance the water level, deciding which coins to click first, and choosing when to use purchased wishes. Every action has visual/sound feedback, making even simple clicks feel impactful【52†L278-L287】.

## 2. Core Game Loop Breakdown
1. **Spawn Coins:** A Timer spawns coins at varying X positions above the fountain. In *Phase 1* (0–15s) only Bronze coins appear. *Phase 2* (15–35s) introduces Silver coins. *Phase 3* (35s+) adds Gold coins and accelerates spawn frequency. For example, `spawn_interval` starts at 1.0s and linearly decreases (capped at 0.25s, i.e. 4 coins/sec). This progressively raises difficulty.
2. **Water Level Update:** As each coin lands, it triggers the water-area script which increases a `water_height` value (smoothly with a `lerp`) based on that coin’s `water_increase`. The fountain’s animated water sprite rises accordingly.  
3. **Player Clicks:** The player clicks (or taps) coins to remove them. Each coin has a larger invisible `Area2D` (2–3× sprite radius) to ease clicks for “fat fingers.” On click, the coin plays a pop animation and sound (a quick scale-pulse and chime【52†L278-L287】), then is freed. The `water_height` is decreased by that coin’s amount.  
4. **Score (Favor) Gain:** Clicking a coin grants Favor: Bronze +1, Silver +3, Gold +5. Favor accumulates and is spent in-game (see Wish section).  
5. **Check Overflow:** Each frame, the GameManager checks `water_height`. If the animated water sprite’s top touches or exceeds Y=250, immediate Game Over occurs (the water is laser-hot!). A warning effect (e.g. water bubbling or UI flash) can appear just before for polish.
6. **Wishes & Shop:** When paused, the player accesses the Wish/Shop menu to spend Favor on lifelines (see Wish System).

This loop constantly pressures the player: coin stacks rise water, clicks remove them, all while new coins keep falling. The introduction of coins by phase and life-saving purchases ensures strategic decision-making each moment.

## 3. Evaluation Strategy
- **Theme (Micromanagement):** The design forces continuous small actions to prevent a fluid catastrophe. The water-level system is a vivid meter of failure, emphasizing constant attention and quick micro-decisions (click this coin or that). The shop adds strategic pauses to plan usage of limited resources, deepening the micromanagement theme.
- **Special Object (Coins):** Coins are ubiquitous and varied. Distinct physics and rewards make each coin meaningful. For example, heavy Gold coins (high mass, low bounce) slam into the pile – clicking one yields +5 Favor, but ignoring it quickly overflows the fountain. The coin types (Bronze, Silver, Gold) are clearly differentiated visually and in value, reinforcing their importance. 
- **Visuals (Clarity + Juice):** Clarity is ensured by high-contrast coin sprites on the fountain background, and the clear Laser Line UI marker for fail threshold. Each action is juiced: coins have click animations (scale/pulse), splash particles trigger on water entry, and the snake eyes softly glow (via sine-wave Light2D tweens) to add atmosphere. Significant events (like a Gold coin’s big impact) cause a camera shake【38†L24-L30】, drawing attention precisely when needed.
- **Audio (Feedback + Layering):** Layered SFX give richness: a click plays a crisp pop plus a random chime, heavy coins add a deep thud, and bubbling/warning sounds cue danger. Background fountain ambient loops quietly. When major milestones (like using Fountain Sweep) occur, a brief jingle reinforces reward. This layering makes each moment sonically informative and satisfying.
- **Gameplay (Depth vs Simplicity):** Core mechanics remain simple (spawn and click coins, water rises), but the phased introduction and Wish shop add depth without complexity. The player isn’t overwhelmed by many systems: they just manage coins and water, but must prioritize coin types and time purchases. This keeps the learning curve shallow but the mastery challenging (clicker design emphasizes keeping basics clear【50†L225-L232】).
- **Polish (Game Feel, Feedback):** Emphasized in audio-visual touches. As one design guide notes, clicking static sprites is unexciting – our coins jump, shrink, or spark on click【56†L281-L288】. Screen shake is applied only on heavy impacts or overflow (not random), giving weight to those moments. The “Water Displacement” lerp makes level changes smooth. All these ensure every micro-action feels impactful and polished.

## 4. Mechanics & Systems
- **Controls (Mouse/Touch, Fat Finger):** Coins can be clicked with a mouse or tapped on mobile. Each coin scene has an invisible `Area2D` (circle shape ~2–3× larger than the coin sprite) for easy hits. In the coin script’s `_input_event` or `_unhandled_input`, we call `set_input_as_handled()` so one click only affects one coin. We also listen for `InputEventScreenTouch` so mobile browsers work seamlessly. This simple upgrade prevents missed or multi-click issues and supports all platforms.

- **Water Displacement (Fail State):** Instead of tracking coin height, we use a continuous water level. Each coin has a `water_increase` value (e.g. Bronze=5px, Silver=10px, Gold=20px). When a coin enters the fountain’s `Area2D`, we set `water_target = water_height + water_increase` and tween the `water_height` property toward it. Similarly, removing a coin subtracts from `water_height`. Every frame we compare `water_height` to the Laser Line at Y=250. If `water_height` >= 250, **Game Over** instantly. This makes overflow logic deterministic and smooth.

- **Wish Shop (Player-Driven Economy):** The Pause menu doubles as a Wish Shop where the player spends Favor to trigger effects. No random timers – the player chooses. The shop is a simple UI overlay listing options. Purchasing works by deducting Favor and invoking an effect. (Tier 2 feature, as it significantly impacts strategy.) The **Wish Roster** (cost in Favor): 
  - **Chain Reaction (25):** Next coin clicked also **pops 4 random other coins** instantly.
  - **Bronze Banish (50):** Immediately removes all Bronze coins on screen.
  - **Coin Bomb (75):** The next click creates an **explosion radius** (180px) popping any coin in range.
  - **Breathing Room (90):** Pauses the coin spawner for 5 seconds (no new coins fall).
  - **Fountain Sweep (150):** Clears **all coins** currently on screen (ultimate panic button).

  These are implemented via signals or callbacks: e.g. Chain Reaction sets a flag so that after the player clicks a coin, the coin script randomly frees 4 more coins. This system adds high risk/reward strategy – saving up for big Lifelines versus spending for minor relief.

- **Coin Physics and Values:** Each coin is a `RigidBody2D` with physics material:
  - **Bronze (Normal):** Moderate mass and bounce, friction ~0.5. Clicking gives +1 Favor.
  - **Silver (Bouncy):** Lighter and very bouncy (bounce≈0.8)【48†L310-L318】, creating chaotic motion. Clicking gives +3 Favor.
  - **Gold (Heavy):** High mass, low bounce (nearly 0). They slam into piles. Clicking gives +5 Favor.
  These roles invert the original: heavy→Gold, bouncy→Silver. Assigning Favor values encourages clicking higher-risk coins. The physics ensure Gold coins trigger big camera shake on impact【38†L24-L30】, and Silver coins bounce unpredictably, fulfilling their roles.

## 5. Entities (Coins)
- **Bronze Coin:** Base coin type. RigidBody2D with small mass, moderate bounce. Role: steady but low value. Strategy: easy clicks for slow Favor gain.
- **Silver Coin:** Chaotic coin (bouncy). RigidBody2D with low mass, high restitution. Role: adds disorder; removing it awards +3 Favor. Strategy: sometimes skip it unless it's causing trouble.
- **Gold Coin:** Heavy coin. RigidBody2D with high mass, negligible bounce. Role: major threat and reward (+5 Favor). Its impact triggers a large camera shake (using camera trauma). Strategy: prioritize clicking these to avoid big water surges.

Each coin’s `water_increase` (for fountain level) can also scale with type (e.g. Gold adds more to water). Visual distinctions (bronze, silver, gold textures) make them recognizable. These types must exist from early on (Phase 3 introduces Gold coins) to align with difficulty phases.

## 6. Progression & Difficulty
A **Phased Progression** approach ramps pressure:

- **Phase 1 (0–15s): Tutorial/Easy.** 100% Bronze coins. Spawn interval starts slow (e.g. 1.0s) and gradually speeds. This lets players get used to clicking and water mechanics with low risk.  
- **Phase 2 (15–35s): Chaos Begins.** Silver coins begin appearing (~10–20% spawn chance). Their bounciness adds unpredictability, and spawn rate continues to ramp (interval down). Player must adapt to bouncing coins.  
- **Phase 3 (35s+): Hard Mode.** Gold coins introduced (~10% chance). Now all three types fall, and `spawn_interval` decreases rapidly (e.g. interval = max(0.25, 1.0 – 0.02×seconds_elapsed)). Eventually up to 4 coins/sec. By this phase, players must constantly click and use Wish lifelines to survive. 

This system keeps gameplay gradually intensifying without adding new mechanics beyond spawning logic changes. Each phase is clearly signaled by coin color diversity and timer, so players know how things have changed.

## 7. Wish System (Shop Economy)
*(Updated from random triggers to player-driven shop)*

- **Pause/Wish Menu:** Hitting pause (or a “wish” button) brings up the Wish Shop. It lists the available lifelines and their Favor costs (see above). The player can choose any, spending Favor and resuming the game. Effects apply immediately (or on next click). No random intervals now – buying is purely player-driven risk/reward.

- **Implementation:** Each Wish is a script/flag checked in game logic. For example, Chain Reaction sets a boolean so that on the *next* coin click, 4 additional coins are popped. Fountain Sweep immediately iterates over all coins and frees them, along with a large particle effect. Breathing Room stops the spawn Timer for 5s (showing a "Paused" flash). After activation, the lifeline is removed until the player can afford it again.

By moving Wishes to a shop, strategy deepens: Should I spend 90 Favor on Breathing Room now, or save up for the 150 Favor Fountain Sweep later? This trades off immediate relief vs. big payoff, strongly engaging the “economy” theme.

## 8. Juice & Game Feel (Visual/Audio Polish)
- **Scene Art:** The fountain now has detailed Snake Statues forming a U-shape (`CollisionPolygon2D` ensures coins bounce correctly off slopes). The snakes have glowing eyes: each head has a `PointLight2D` node whose energy pulses via a sine tween, adding atmosphere.
- **Water Animation:** The water is a 6-frame looping sprite (animated over 0.5s). An `Area2D` collider for water is a child of this animated node, so rain/splash particles trigger at the correct moving surface position. When coins land, spark/splash particles emit at the contact point.
- **Camera Shake (Targeted):** Camera shake is triggered **only** by large impacts. Specifically, if a Gold coin’s vertical velocity suddenly drops (collision with ground/coins), we call `add_trauma(1.0)` (high intensity). Also, if the water overflows, we trigger a very strong shake. Smaller coins or clicks do not shake the camera. This focused use makes big moments feel dramatic without disorienting the player constantly【38†L24-L30】.
- **UI Effects:** When water gets dangerously high, the Laser Line glows (e.g. a red pulsating sprite). Clicking coins causes the coin sprites to briefly enlarge and emit a burst of star particles【52†L278-L287】. The score label briefly “pops” (scale animation) on gains. Sound effects (pop, splash, warning beep) are carefully timed with animations for crisp feedback.
- **Audio Layering:** We layer a low-volume ambient soundtrack under SFX. Clicks have a distinct sharp sound; Gold thuds add bass. When Wishes are used, a special jingle plays. Background sounds (flowing water) duck under critical sounds to ensure clarity (in line with best practices for focus).

Overall, these visuals and sounds ensure each click and event feels lively and rewarding【52†L278-L287】. The fountain and UI elements are hand-drawn but simple, fitting a jam scope, yet enhanced by these dynamic details.

## 9. MVP Asset List (Revised)
- **Sprites:**  
  - Coin graphics for Bronze, Silver, Gold (distinct colors).  
  - Snake fountain background with precise collision shape.  
  - Water sprite (6-frame animation).  
  - UI elements (score counter, Laser Line).  
  - Pause/Wish menu buttons/icons for each lifeline.
- **Particles:**  
  - Small gold sparkles for coin bursts.  
  - Water splash effect.  
  - Laser warning glow.
- **Animations:**  
  - Coin click (scale/pulse) animation.  
  - Snake eye light pulsing (ColorRect or tween).  
  - UI elements (score pop).
- **Audio:**  
  - Click/pop sound, heavy thud, bounce ring.  
  - Water bubble/warning sound.  
  - Short “level up” or “wish used” chimes.
- **Scenes/Nodes:**  
  - Main scene with Snake statues and fountain.  
  - Coin scene with large Area2D hitbox.  
  - Wish Shop UI scene.  
  - Camera2D with shake script.  

Keep art/simple (flat colors, no complex textures). The above provides necessary polish without undue time cost.

## 10. Godot Architecture
- **Main Scene (Node2D):**  
  - `Camera2D` (with shake script for targeted trauma).  
  - `SnakeFountain (Node2D)` containing:  
    - Snake statue sprites with `CollisionPolygon2D` shapes.  
    - Snake eyes (`PointLight2D` on tweens).  
    - `Water (AnimatedSprite2D)` + child `Area2D` with CollisionShape (water area trigger).  
  - `Spawner (Node)` running coin spawn Timer.  
  - `UI (CanvasLayer)` including ScoreLabel, LaserLineIndicator, Pause/WishMenu.  
  - `GameOverScreen` (CanvasLayer, hidden until triggered).  
- **Coin Scene (`RigidBody2D`):**  
  - `Sprite2D` (coin art).  
  - `CollisionShape2D` (circle matching sprite).  
  - `Area2D (Hitbox)` with larger circle collision shape (invisible).  
  - `Coin.gd` script: handles `_input_event` (mouse/touch), plays pop VFX, signals GameManager, and `queue_free()`. Calls `set_input_as_handled()`. Also checks if a Wish effect (like Chain Reaction) is active to pop extra coins.
- **Wish Shop UI:**  
  - Control nodes for each lifeline button (with cost label). On click, emit a signal to GameManager to activate the effect and deduct Favor.
- **Scripts:**  
  - **GameManager.gd:** Tracks `water_height`, Favor score, spawns coins, checks overflow. Connects coin removal to updating water and score. Handles Wish activations. Triggers GameOver when needed.  
  - **ShakeCamera.gd:** Attached to Camera2D, implements the trauma shake (decay over time)【38†L24-L30】. Provides `add_trauma(amount)` for heavy coin impacts and overflow.  
  - **Coin.gd:** On click, calls `GameManager.coin_clicked(self)`. May also call `GameManager.apply_chain_reaction()` etc.  
  - **Input Handling:** Works with `_input_event` on coins; ensures multi-clicks prevented via `set_input_as_handled()`【57†L1-L4】. Also game listens to `InputEventScreenTouch`.

This architecture cleanly separates concerns: physics and visuals in scenes, game logic in scripts. The key addition is the Wish Shop signal flow and the water-level logic in GameManager. 

## 11. Core Code Concepts
- **Water Tween:** When a coin falls in:  
  ```gdscript
  func _on_Coin_entered_water(amount):
      water_target = water_height + amount
      tween.interpolate_property(self, "water_height", water_height, water_target, 0.5, Tween.TRANS_SINE)
      tween.start()
  ```
  On coin click removal: `water_height = max(0, water_height - coin.amount)`.
- **Click Detection:**  
  ```gdscript
  func _input_event(viewport, event, shape):
      if event is InputEventMouseButton and event.pressed or event is InputEventScreenTouch:
          set_input_as_handled()
          GameManager.coin_clicked(self)
  ```
- **Wish Effects (example Chain Reaction):**  
  ```gdscript
  var chain_reaction_active = false
  func on_chain_reaction_purchased():
      chain_reaction_active = true
  func coin_clicked(coin):
      if chain_reaction_active:
          chain_reaction_active = false
          pop_random_coins(4)
  ```
- **Overflow Check:** In `GameManager._physics_process`:  
  ```gdscript
  if water_height >= LASER_LINE_Y:
      trigger_game_over()
  ```
- **Phase Logic:** After 15s, set spawn logic to allow Silver; after 35s, allow Gold and adjust Timer wait time dynamically.  

These code outlines capture the new systems. All code is GDScript-friendly and avoids over-engineering (e.g. using built-in tweens and signals). 

## 12. Development Schedule (Revised 7 Days)
- **Day 1:** *Core mechanics & Fail Logic* (3–4h) – Implement basic spawn & click loop. Replace original height check with water displacement and lerp (ensure Game Over at Y=250). Test Bronze coins only. Set up RigidBody2D coins and fountain collisions【54†L327-L330】.
- **Day 2:** *Coins & Scoring* (4h) – Add Silver and Gold coin prefabs with correct physics and values. Adjust spawn phases (introduce Silver at t=15s). Implement Favor scoring (+1/+3/+5). Ensure coin hitboxes are fat (bigger Area2D) and input works on mobile.
- **Day 3:** *Progression & Spawning* (4h) – Phase control: Bronze-only (0–15s), spawn Silver next (15–35s), Gold after (35s+). Speed up spawn timer in Phase 3 (cap at 0.25s). Polish spawn randomness. Add small UI text showing phase transition (optional).
- **Day 4:** *Wish System UI & Effects* (4h) – Build the Pause/Wish menu UI. Code each Wish effect (Chain Reaction, Bronze Banish, etc.) and test them one by one. Hook buttons to deduct Favor and activate effects. Balance costs roughly.
- **Day 5:** *Polish Visuals* (4h) – Integrate snake fountain art with CollisionPolygon2D. Animate snake eyes with sine-tweened PointLight2D. Replace water sprite with animated frames and parent its Area2D. Tune particles on coin splash. Implement targeted camera shake on Gold impact (call `add_trauma(…)` on collision event) and on overflow.
- **Day 6:** *Audio & Feedback* (3h) – Add SFX (pop, thud, alerts) and small music loop. Add UI feedback (score pop animation, Laser Line glow). Adjust any gameplay feedback (like brief slowdown flash on failing).
- **Day 7:** *Buffer & QA* (2–3h) – Fix bugs (overflow edge cases, Wish timing). Fine-tune difficulty (phase timings or costs). Ensure performance is stable. Prepare build and polish interface text/icons.

**Buffer Time:** Note we allocate ~20% extra as per jam best practices【45†L244-L252】, so any overruns won’t derail the core build. The goal is to have a fully playable build by Day 5, then spend remaining time polishing presentation and fixing issues.  

These tasks reflect the implemented changes and ensure all new features (water system, Wish shop, new coins, etc.) are complete while retaining high polish on game feel【52†L278-L287】【38†L24-L30】.

