package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUsername(String username);
    List<User> findByRole(String role);
    List<User> findByStoreId(Integer storeId);

    long countByIsActive(Boolean isActive);
    boolean existsByUsername(String username);
}
