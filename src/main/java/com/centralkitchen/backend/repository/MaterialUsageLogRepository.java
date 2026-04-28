package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.MaterialUsageLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MaterialUsageLogRepository extends JpaRepository<MaterialUsageLog, Integer> {
}
