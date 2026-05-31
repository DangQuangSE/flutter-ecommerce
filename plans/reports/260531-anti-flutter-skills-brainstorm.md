# Brainstorm: Antigravity Code Skills cho Flutter Clean Architecture

**Date:** 2026-05-31

## Ideas Explored

- **Chỉ RULES.md** — file convention đơn giản, agent đọc tự động. Nhanh nhưng không có scaffold command.
- **Chỉ Skills gọi tường minh** — slash commands như /add-feature, /fix-arch. Mạnh nhưng thiếu baseline rules.
- **RULES.md + Skills + References** — được chọn. Kết hợp passive rules (luôn active) + active skills (gọi khi cần scaffold) + reference docs (code templates).
- **Package modular (mỗi feature là Dart package)** — bị loại, quá sớm cho MVP scale.
- **Chỉ system prompt** — không dùng, không versioned cùng codebase.

## User's Direction

Antigravity AI coding agent (giống Cursor/Copilot) với skill system giống `.claude/skills/`. Vấn đề: agent generate code không theo folder structure, bỏ qua domain layer, dùng BLoC sai. Giải pháp: `.anti-flutter/` với RULES.md (passive) + skills (active) + references (templates).

Format: giống hệt `.claude/skills/` — YAML frontmatter + markdown body.

## Open Questions

- Antigravity có auto-load RULES.md từ root không, hay phải config trong settings?
- Skill `/fix-arch` cần scan codebase thực hay chỉ checklist heuristic?
- Có cần skill `/add-cubit` riêng hay dùng chung `/add-bloc`?

## Risks

1. Nếu Antigravity không auto-load RULES.md, rules nền mất tác dụng — phải kiểm tra settings
2. Skill templates phải được cập nhật khi codebase thay đổi (ví dụ: thêm feature mới, đổi package) — dễ outdated
3. Agent vẫn có thể ignore rules nếu user prompt không nhắc đến architecture — cần discipline từ cả hai phía
