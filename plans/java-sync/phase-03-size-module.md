# Phase 3: Size Module (new)

## Requirements
Create a new `modules/size/` package containing `SizeGroup` and `SizeOption` JPA entities and their Spring Data repositories. These entities back the `size_groups` and `size_options` DB tables and will be referenced by the `Product` entity in Phase 4. No controllers or service layer is needed in this phase.

## Steps

1. Create `SizeGroup.java` entity in `modules/size/domain/`. Map it to table `size_groups`. Include: auto-generated `id`, `name` (unique, not null, length 100), `description` (length 255, nullable), and a `List<SizeOption> sizes` one-to-many collection (cascade ALL, orphanRemoval, fetch EAGER, ordered by `displayOrder ASC`). Use `@Getter @Setter @NoArgsConstructor` — no `@Builder` needed.

2. Create `SizeOption.java` entity in `modules/size/domain/`. Map it to table `size_options`. Include: auto-generated `id`, `name` (not null, length 50), `displayOrder` (not null, default 0), and a `@ManyToOne(fetch = LAZY)` back-reference to `SizeGroup` via FK column `size_group_id` (not null). Annotate the collection ordering with `@Column(name = "display_order", nullable = false, columnDefinition = "int default 0")`.

3. Create `SizeGroupRepository.java` in `modules/size/repository/` extending `JpaRepository<SizeGroup, Long>`. Add `boolean existsByName(String name)` for future uniqueness checks. Annotate with `@Repository`.

4. Create `SizeOptionRepository.java` in `modules/size/repository/` extending `JpaRepository<SizeOption, Long>`. Annotate with `@Repository`.

5. Start the application locally and verify the two tables are created in the DB via `ddl-auto=update`. No seed data is required.

## Files to Create

### `src/main/java/com/sport_pro_be/modules/size/domain/SizeGroup.java`
```java
package com.sport_pro_be.modules.size.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "size_groups")
public class SizeGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(length = 255)
    private String description;

    @OneToMany(
        mappedBy = "sizeGroup",
        cascade = CascadeType.ALL,
        orphanRemoval = true,
        fetch = FetchType.EAGER
    )
    @OrderBy("displayOrder ASC")
    private List<SizeOption> sizes = new ArrayList<>();
}
```

### `src/main/java/com/sport_pro_be/modules/size/domain/SizeOption.java`
```java
package com.sport_pro_be.modules.size.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "size_options")
public class SizeOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(name = "display_order", nullable = false, columnDefinition = "int default 0")
    private Integer displayOrder = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "size_group_id", nullable = false)
    private SizeGroup sizeGroup;
}
```

### `src/main/java/com/sport_pro_be/modules/size/repository/SizeGroupRepository.java`
```java
package com.sport_pro_be.modules.size.repository;

import com.sport_pro_be.modules.size.domain.SizeGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SizeGroupRepository extends JpaRepository<SizeGroup, Long> {
    boolean existsByName(String name);
}
```

### `src/main/java/com/sport_pro_be/modules/size/repository/SizeOptionRepository.java`
```java
package com.sport_pro_be.modules.size.repository;

import com.sport_pro_be.modules.size.domain.SizeOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SizeOptionRepository extends JpaRepository<SizeOption, Long> {
}
```

## Success Criteria
- Application starts without Hibernate mapping errors
- `size_groups` table exists in DB with columns: `id`, `name` (UNIQUE NOT NULL), `description`
- `size_options` table exists in DB with columns: `id`, `name` (NOT NULL), `display_order` (NOT NULL DEFAULT 0), `size_group_id` (FK NOT NULL)
- Foreign key constraint from `size_options.size_group_id` to `size_groups.id` is present

## Risks
- `@OrderBy("displayOrder ASC")` uses the Java field name — now safe because `@Column(name = "display_order")` is explicitly set on `SizeOption.displayOrder`, making the mapping unambiguous regardless of naming strategy.
- EAGER fetch on `SizeGroup.sizes` will load all options every time a `SizeGroup` is fetched — acceptable given the small cardinality of size options per group.

## Dependencies
- None. This phase is fully independent.
