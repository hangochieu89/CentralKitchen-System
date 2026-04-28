package com.centralkitchen.backend.service;

import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class KitchenStaffService {
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private ProductionPlanRepository productionPlanRepository;
    
    @Autowired
    private ProductBatchRepository productBatchRepository;
    
    @Autowired
    private InventoryRepository inventoryRepository;
    
    @Autowired
    private GoodsReceiptRepository goodsReceiptRepository;

    @Autowired
    private GoodsReceiptDetailRepository goodsReceiptDetailRepository;

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    public List<ProductionPlan> getAllProductionPlans() {
        return productionPlanRepository.findAll();
    }

    public List<ProductBatch> getAllProductBatches() {
        return productBatchRepository.findAll();
    }

    public List<Inventory> getAllInventories() {
        return inventoryRepository.findAll();
    }

    public List<GoodsReceipt> getAllGoodsReceipts() {
        return goodsReceiptRepository.findAll();
    }
    
    public List<GoodsReceiptDetail> getAllGoodsReceiptDetails() {
        return goodsReceiptDetailRepository.findAll();
    }
}
