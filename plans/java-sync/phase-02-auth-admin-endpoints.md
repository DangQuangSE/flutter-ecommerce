# Phase 2: Auth — AdminUserController endpoints

## Requirements
Expose three admin-only endpoints — update user role, toggle user active status, and hard-delete a user — backed by proper DTO records and service methods. Matches the API contract of `sport_pro_be` `AdminUserController`.

## Steps

1. Create `UpdateUserRoleRequest.java` as a Java record with a single `@NotNull Role role` component. Place it in `modules/auth/dto/`.

2. Create `UpdateUserActiveRequest.java` as a Java record with a single `boolean active` component. Place it in `modules/auth/dto/`.

3. Add three method signatures to `IProfileService.java`:
   - `UserProfileResponse updateUserRole(Long userId, Role role)`
   - `UserProfileResponse setUserActive(Long userId, boolean active)`
   - `void deleteUser(Long userId)`

4. Implement the three methods in `ProfileService.java`. Each method looks up the user by id (throw `ResourceNotFoundException` if absent), mutates the relevant field, calls `userRepository.save(user)`, and returns `mapToResponse(user)`. `deleteUser` calls `userRepository.deleteById(userId)` (hard-delete, no save needed) and returns void.

5. Add three endpoint methods to `AdminUserController.java` with `@PreAuthorize("hasRole('ADMIN')")` already inherited from the class-level annotation. Wire them to the new service methods and return `ApiResponse.of(...)`.

## Files to Create

### `src/main/java/com/sport_pro_be/modules/auth/dto/UpdateUserRoleRequest.java`
```java
package com.sport_pro_be.modules.auth.dto;

import com.sport_pro_be.modules.auth.enums.Role;
import jakarta.validation.constraints.NotNull;

public record UpdateUserRoleRequest(
    @NotNull(message = "Role is required")
    Role role
) {}
```

### `src/main/java/com/sport_pro_be/modules/auth/dto/UpdateUserActiveRequest.java`
```java
package com.sport_pro_be.modules.auth.dto;

public record UpdateUserActiveRequest(
    boolean active
) {}
```

## Files to Edit

### `IProfileService.java` — add three signatures:
```java
import com.sport_pro_be.modules.auth.enums.Role;

// add to existing interface:
UserProfileResponse updateUserRole(Long userId, Role role);
UserProfileResponse setUserActive(Long userId, boolean active);
void deleteUser(Long userId);
```

### `ProfileService.java` — add three implementations:
```java
@Override
@Transactional
@Loggable(action = "UPDATE_USER_ROLE", module = "AUTH")
public UserProfileResponse updateUserRole(Long userId, Role role) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    user.setRole(role);
    user = userRepository.save(user);
    return mapToResponse(user);
}

@Override
@Transactional
@Loggable(action = "SET_USER_ACTIVE", module = "AUTH")
public UserProfileResponse setUserActive(Long userId, boolean active) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    user.setActive(active);
    user = userRepository.save(user);
    return mapToResponse(user);
}

@Override
@Transactional
@Loggable(action = "DELETE_USER", module = "AUTH")
public void deleteUser(Long userId) {
    if (!userRepository.existsById(userId)) {
        throw new ResourceNotFoundException("User not found");
    }
    userRepository.deleteById(userId);
}
```

### `AdminUserController.java` — add three endpoint methods:
```java
import com.sport_pro_be.modules.auth.dto.UpdateUserRoleRequest;
import com.sport_pro_be.modules.auth.dto.UpdateUserActiveRequest;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;

// add to existing class body:

@PutMapping("/{id}/role")
public ApiResponse<UserProfileResponse> updateUserRole(
        @PathVariable Long id,
        @Valid @RequestBody UpdateUserRoleRequest request) {
    return ApiResponse.of("User role updated successfully",
            profileService.updateUserRole(id, request.role()));
}

@PutMapping("/{id}/active")
public ApiResponse<UserProfileResponse> setUserActive(
        @PathVariable Long id,
        @RequestBody UpdateUserActiveRequest request) {
    return ApiResponse.of("User active status updated successfully",
            profileService.setUserActive(id, request.active()));
}

@DeleteMapping("/{id}")
public ApiResponse<Void> deleteUser(@PathVariable Long id) {
    profileService.deleteUser(id);
    return ApiResponse.of("User deleted successfully", null);
}
```

**MANDATORY**: Add `@PreAuthorize("hasRole('ADMIN')")` at the class level on `AdminUserController` — confirmed absent in source. The class-level annotation ensures all mappings are protected without per-method repetition. Without it, SecurityConfig URL-pattern security is the only guard, which is fragile under package/path changes.

```java
@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")     // ADD THIS
public class AdminUserController {
```

## Success Criteria
- `PUT /api/admin/users/{id}/role` with body `{"role":"ADMIN"}` returns `200` with updated `UserProfileResponse` containing `"role": "ADMIN"`
- `PUT /api/admin/users/{id}/active` with body `{"active":false}` returns `200` with `"isActive": false` in response
- `DELETE /api/admin/users/{id}` returns `200`; subsequent `GET /api/admin/users/{id}` returns 404
- Invalid role value (e.g. `{"role":"SUPERUSER"}`) returns `400` validation error
- Attempting to update/delete a non-existent user ID returns `404`

## Risks
- `User.setActive()` setter name: Lombok generates `setActive(boolean)` for a field named `isActive` (primitive boolean). Confirm this matches — if the field is declared as `boolean isActive`, Lombok `@Setter` generates `setActive(boolean active)`. Do not use `setIsActive`.
- Hard-delete of a user who has FK references (orders, cart) will throw a DB constraint violation — mitigation: out of scope for this phase; noted in spec as expected behaviour matching sport_pro_be.

## Dependencies
- Phase 1 must be complete. `UserProfileResponse` must include `isActive` before these endpoints return meaningful data.
