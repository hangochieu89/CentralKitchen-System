package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUsername(String username);

    @Query("SELECT u FROM User u LEFT JOIN FETCH u.store WHERE u.id = :id")
    Optional<User> findByIdWithStore(@Param("id") Integer id);
    List<User> findByRole(String role);
    List<User> findByStoreId(Integer storeId);

    long countByIsActive(Boolean isActive);
    boolean existsByUsername(String username);
}
