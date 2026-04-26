package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "QualityFeedbacks")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QualityFeedback {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "delivery_id", nullable = false)
    private Delivery delivery;

    @ManyToOne
    @JoinColumn(name = "submitted_by", nullable = false)
    private User submittedBy;

    private Integer rating; // 1 - 5

    @Column(length = 1000)
    private String comment;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt = LocalDateTime.now();
}