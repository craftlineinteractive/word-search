# Task Plan: Star-Based Rewards, Level Stars by Hint Usage, and World Unlock Rebalancing

## Goal
1. Address Android startup splash behavior cleanly and without delay.
2. Ensure achievements give exactly 3 rewards per achievement, each tied to completing Star 1, Star 2, and Star 3.
3. Track level stars based on hints used:
   - 0 hints used -> 3 stars
   - 1 hint used -> 2 stars
   - 2+ hints used (or skipped) -> 1 star
   Show stars earned on victory dialog and level map tiles.
4. Ensure required stars for unlocking subsequent worlds are reasonable and achievable for any player.
5. Verify on connected Android device and run all tests.

## Phases
- [ ] Phase 1: Planning & Discoveries (task_plan.md, findings.md, progress.md)
- [ ] Phase 2: Android Startup Splash (values-night & values-night-v31 consistency)
- [ ] Phase 3: Achievement Star-Based Rewards (Star 1, Star 2, Star 3 UI and claim flow)
- [ ] Phase 4: Hint-Based Level Stars Tracking & UI Presentation
- [ ] Phase 5: Rebalance World Unlock Required Stars
- [ ] Phase 6: Device Verification & Test Suite Execution
