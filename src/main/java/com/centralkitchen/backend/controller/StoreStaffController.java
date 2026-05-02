package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.dto.OrderRequest;
import com.centralkitchen.backend.dto.StoreInventoryDeltaRequest;
import com.centralkitchen.backend.dto.StoreInventorySummaryDTO;
import com.centralkitchen.backend.dto.StoreOrderDetailDTO;
import com.centralkitchen.backend.dto.StoreProductCatalogDTO;
import com.centralkitchen.backend.dto.StoreStaffFeedbackRequest;
import com.centralkitchen.backend.dto.StoreStocktakeRequest;
import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.UserRepository;
import com.centralkitchen.backend.service.StoreStaffService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/store-staff")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StoreStaffController {

    private final StoreStaffService storeStaffService;
    private final UserRepository userRepository;

    private User currentStoreStaff(HttpSession session) {
        User raw = (User) session.getAttribute("currentUser");
        if (raw == null) {
            throw new IllegalStateException("UNAUTHORIZED");
        }
        return userRepository.findByIdWithStore(raw.getId())
                .orElseThrow(() -> new IllegalStateException("UNAUTHORIZED"));
    }

    private ResponseEntity<?> bad(String msg, HttpStatus status) {
        return ResponseEntity.status(status).body(Map.of("success", false, "message", msg));
    }

    @GetMapping("/inventory/{storeId}")
    public ResponseEntity<?> getInventory(HttpSession session, @PathVariable Integer storeId) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.getMyStoreInventory(storeId, u));
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/inventory/{storeId}/summary")
    public ResponseEntity<?> getInventorySummary(HttpSession session, @PathVariable Integer storeId) {
        try {
            User u = currentStoreStaff(session);
            StoreInventorySummaryDTO summary = storeStaffService.getInventorySummary(storeId, u);
            return ResponseEntity.ok(summary);
        } catch (IllegalArgumentException e) {
            return storeStaffInventoryError(e);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/inventory/{storeId}/stocktake")
    public ResponseEntity<?> postStocktake(HttpSession session,
                                           @PathVariable Integer storeId,
                                           @Valid @RequestBody StoreStocktakeRequest body) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.applyStocktake(storeId, body, u));
        } catch (IllegalArgumentException e) {
            return storeStaffInventoryError(e);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/inventory/{storeId}/delta")
    public ResponseEntity<?> postInventoryDelta(HttpSession session,
                                                @PathVariable Integer storeId,
                                                @Valid @RequestBody StoreInventoryDeltaRequest body) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.applyInventoryDelta(storeId, body, u));
        } catch (IllegalArgumentException e) {
            return storeStaffInventoryError(e);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    private ResponseEntity<?> storeStaffInventoryError(IllegalArgumentException e) {
        String msg = e.getMessage() != null ? e.getMessage() : "";
        if (msg.contains("cửa hàng khác")) {
            return bad(msg, HttpStatus.FORBIDDEN);
        }
        return bad(msg, HttpStatus.BAD_REQUEST);
    }

    @PostMapping("/orders")
    public ResponseEntity<?> createOrder(HttpSession session, @RequestBody OrderRequest request) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.createOrder(request, u));
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/orders/{storeId}")
    public ResponseEntity<?> getOrders(HttpSession session, @PathVariable Integer storeId) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.listStoreOrders(storeId, u));
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/orders/{orderId}/confirm-receipt")
    public ResponseEntity<?> confirmReceipt(HttpSession session, @PathVariable Integer orderId) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.confirmReceipt(orderId, u));
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/feedback")
    public ResponseEntity<?> postFeedback(HttpSession session,
                                          @Valid @RequestBody StoreStaffFeedbackRequest body) {
        try {
            User u = currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.submitFeedback(body, u));
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/products")
    public ResponseEntity<?> getAllProducts(HttpSession session) {
        try {
            currentStoreStaff(session);
            return ResponseEntity.ok(storeStaffService.getAllProducts());
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/products/catalog")
    public ResponseEntity<?> getProductCatalog(HttpSession session) {
        try {
            currentStoreStaff(session);
            StoreProductCatalogDTO catalog = storeStaffService.getProductCatalog();
            return ResponseEntity.ok(catalog);
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/orders/detail/{orderId}")
    public ResponseEntity<?> getOrderDetails(HttpSession session, @PathVariable Integer orderId) {
        try {
            User u = currentStoreStaff(session);
            StoreOrderDetailDTO dto = storeStaffService.getOrderDetails(orderId, u);
            return ResponseEntity.ok(dto);
        } catch (IllegalArgumentException e) {
            return bad(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
}
