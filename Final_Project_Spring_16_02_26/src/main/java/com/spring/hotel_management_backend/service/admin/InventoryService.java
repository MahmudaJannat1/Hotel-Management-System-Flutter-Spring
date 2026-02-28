package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.inventory.*;
import com.spring.hotel_management_backend.model.dto.response.admin.inventory.*;

import java.time.LocalDate;
import java.util.List;

public interface InventoryService {

    // ========== Inventory Items ==========
    InventoryItemResponse createInventoryItem(CreateInventoryItemRequest request);
    List<InventoryItemResponse> getAllInventoryItems(Long hotelId);
    InventoryItemResponse getInventoryItemById(Long id);
    List<InventoryItemResponse> getInventoryItemsByCategory(Long hotelId, String category);
    List<InventoryItemResponse> getLowStockItems(Long hotelId);
    List<InventoryItemResponse> getExpiringItems(Long hotelId, Integer days);
    InventoryItemResponse updateInventoryItem(Long id, UpdateInventoryItemRequest request);
    InventoryItemResponse adjustStock(Long id, StockAdjustRequest request);
    void deleteInventoryItem(Long id);

    // ========== Suppliers ==========
    SupplierResponse createSupplier(CreateSupplierRequest request);
    List<SupplierResponse> getAllSuppliers(Long hotelId);
    SupplierResponse getSupplierById(Long id);
    List<SupplierResponse> searchSuppliers(String searchTerm);
    SupplierResponse updateSupplier(Long id, CreateSupplierRequest request);
    void deleteSupplier(Long id);

    // ========== Purchase Orders ==========
    PurchaseOrderResponse createPurchaseOrder(CreatePurchaseOrderRequest request);
    List<PurchaseOrderResponse> getAllPurchaseOrders(Long hotelId);
    PurchaseOrderResponse getPurchaseOrderById(Long id);
    PurchaseOrderResponse getPurchaseOrderByNumber(String poNumber);
    List<PurchaseOrderResponse> getPurchaseOrdersBySupplier(Long supplierId);
    List<PurchaseOrderResponse> getPurchaseOrdersByStatus(Long hotelId, String status);
    List<PurchaseOrderResponse> getPendingDeliveries(Long hotelId);
    PurchaseOrderResponse approvePurchaseOrder(Long id, String approvedBy);
    PurchaseOrderResponse receivePurchaseOrder(Long id, ReceivePurchaseOrderRequest request);
    PurchaseOrderResponse cancelPurchaseOrder(Long id, String reason);

    // ========== Stock Transactions ==========
    List<StockTransactionResponse> getStockTransactions(Long hotelId, LocalDate startDate, LocalDate endDate);
    List<StockTransactionResponse> getItemStockHistory(Long itemId);

    // ========== Reports & Analytics ==========
    Double getTotalInventoryValue(Long hotelId);
    Integer getTotalItemsCount(Long hotelId);
    Integer getLowStockCount(Long hotelId);
}