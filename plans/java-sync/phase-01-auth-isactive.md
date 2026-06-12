# Phase 1: Auth — User.isActive

## Requirements
Add a persisted `isActive` boolean field to the `User` entity and expose it in all profile responses so that admin can read and later toggle user account status. The field must default to `true` in the DB column and in the Java initialiser.

## Steps

1. Add `isActive` field to `User.java` with `@Column(nullable = false, columnDefinition = "boolean default true")` and a Java-level initialiser `= true`. Do NOT add `@Builder.Default` — `User` does not use Lombok `@Builder`.

2. Add `boolean isActive` to the `UserProfileResponse` record as an additional component after `totalSpending`. Because `UserProfileResponse` uses `@Builder`, adding the component extends the builder — update the builder call in step 3 first to avoid a compile error.

3. Update the `mapToResponse(User user)` private helper in `ProfileService` to set `.isActive(user.isActive())` in the builder chain. The method already maps all other fields; add this one line.

4. Verify that `getAllProfiles()` and `getProfile()` both route through `mapToResponse()` — they do (reading the existing code confirms this), so no further changes are needed in those methods.

5. Confirm the DB column will be created automatically: `spring.jpa.ddl-auto=update` will `ALTER TABLE app_users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE` on next startup. No manual migration script is needed for dev.

## Files to Edit

| File | Change |
|------|--------|
| `src/main/java/com/sport_pro_be/modules/auth/domain/User.java` | Add field `private boolean isActive = true;` with `@Column` annotation after the `tier` field |
| `src/main/java/com/sport_pro_be/modules/auth/dto/UserProfileResponse.java` | Add `boolean isActive` component to record definition |
| `src/main/java/com/sport_pro_be/modules/auth/service/ProfileService.java` | Add `.isActive(user.isActive())` in `mapToResponse()` builder chain |

### Exact changes

**User.java** — add after the `tier` field (line 51 in current file):
```java
@Column(nullable = false, columnDefinition = "boolean default true")
private boolean isActive = true;
```

**UserProfileResponse.java** — full replacement (record component added):
```java
package com.sport_pro_be.modules.auth.dto;

import lombok.Builder;
import java.math.BigDecimal;

@Builder
public record UserProfileResponse(
    Long id,
    String email,
    String firstName,
    String lastName,
    String avatar,
    String role,
    String tier,
    BigDecimal totalSpending,
    boolean isActive
) {}
```

**ProfileService.java** — `mapToResponse` method, add one line to the builder:
```java
private UserProfileResponse mapToResponse(User user) {
    return UserProfileResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .firstName(user.getFirstName())
            .lastName(user.getLastName())
            .avatar(user.getAvatar())
            .role(user.getRole().name())
            .tier(user.getTier().name())
            .totalSpending(user.getTotalSpending())
            .isActive(user.isActive())   // NEW
            .build();
}
```

## Step 6: Enforce isActive at Login

In `AuthService.java`, inside the `login(LoginRequest request)` method, add an isActive check **before** the `emailVerified` check:

```java
if (!user.isActive()) {
    throw new UnauthorizedException(ACCOUNT_DELETED);
}
```

If `ACCOUNT_DELETED` does not exist in `AuthConstant.java`, add it:
```java
public static final String ACCOUNT_DELETED = "Account is disabled";
```

**File to edit**: `src/main/java/com/sport_pro_be/modules/auth/service/AuthService.java`

This matches sport_pro_be line 95–97 exactly.

## Success Criteria
- `GET /api/admin/users` response JSON contains `"isActive": true` for every user
- `GET /api/profile` (authenticated) response contains `"isActive"` field
- Application starts without errors; `app_users` table has an `is_active` column after startup
- Existing users without the column get `TRUE` via the column default
- A user with `isActive = false` receives `401 Unauthorized` on login

## Risks
- Compile error if `mapToResponse` is not updated in the same commit as `UserProfileResponse` — mitigation: edit all three files atomically in one commit.
- `UserProfileResponse` record component order matters for positional constructors — only the builder is used in `ProfileService`, so order is safe to append.

## Dependencies
- None. This phase has no prerequisite phases.
