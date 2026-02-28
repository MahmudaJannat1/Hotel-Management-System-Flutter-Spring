package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.inventory.*;
import com.spring.hotel_management_backend.model.dto.response.admin.inventory.*;
import com.spring.hotel_management_backend.service.admin.InventoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/admin/inventory")
@RequiredArgsConstructor
@Tag(name = "Inventory Management", description = "Admin inventory management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class InventoryController {

    private final InventoryService inventoryService;

    // ========== Inventory Items Endpoints ==========

    @PostMapping("/items")
    @Operation(summary = "Create new inventory item")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryItemResponse> createInventoryItem(@RequestBody CreateInventoryItemRequest request) {
        InventoryItemResponse response = inventoryService.createInventoryItem(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping("/items")
    @Operation(summary = "Get all inventory items")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<InventoryItemResponse>> getAllInventoryItems(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getAllInventoryItems(hotelId));
    }

    @GetMapping("/items/{id}")
    @Operation(summary = "Get inventory item by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryItemResponse> getInventoryItemById(@PathVariable Long id) {
        return ResponseEntity.ok(inventoryService.getInventoryItemById(id));
    }

    @GetMapping("/items/category/{category}")
    @Operation(summary = "Get inventory items by category")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<InventoryItemResponse>> getInventoryItemsByCategory(
            @RequestParam(required = false) Long hotelId,
            @PathVariable String category) {
        return ResponseEntity.ok(inventoryService.getInventoryItemsByCategory(hotelId, category));
    }

    @GetMapping("/items/low-stock")
    @Operation(summary = "Get low stock items")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<InventoryItemResponse>> getLowStockItems(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getLowStockItems(hotelId));
    }

    @GetMapping("/items/expiring")
    @Operation(summary = "Get expiring items")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<InventoryItemResponse>> getExpiringItems(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "30") Integer days) {
        return ResponseEntity.ok(inventoryService.getExpiringItems(hotelId, days));
    }

    @PutMapping("/items/{id}")
    @Operation(summary = "Update inventory item")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryItemResponse> updateInventoryItem(
            @PathVariable Long id,
            @RequestBody UpdateInventoryItemRequest request) {
        return ResponseEntity.ok(inventoryService.updateInventoryItem(id, request));
    }

    @PatchMapping("/items/{id}/adjust-stock")
    @Operation(summary = "Adjust stock quantity")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryItemResponse> adjustStock(
            @PathVariable Long id,
            @RequestBody StockAdjustRequest request) {
        return ResponseEntity.ok(inventoryService.adjustStock(id, request));
    }

    @DeleteMapping("/items/{id}")
    @Operation(summary = "Delete inventory item")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteInventoryItem(@PathVariable Long id) {
        inventoryService.deleteInventoryItem(id);
        return ResponseEntity.noContent().build();
    }

    // ========== Suppliers Endpoints ==========

    @PostMapping("/suppliers")
    @Operation(summary = "Create new supplier")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SupplierResponse> createSupplier(@RequestBody CreateSupplierRequest request) {
        SupplierResponse response = inventoryService.createSupplier(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping("/suppliers")
    @Operation(summary = "Get all suppliers")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<SupplierResponse>> getAllSuppliers(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getAllSuppliers(hotelId));
    }

    @GetMapping("/suppliers/{id}")
    @Operation(summary = "Get supplier by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SupplierResponse> getSupplierById(@PathVariable Long id) {
        return ResponseEntity.ok(inventoryService.getSupplierById(id));
    }

    @GetMapping("/suppliers/search")
    @Operation(summary = "Search suppliers")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<SupplierResponse>> searchSuppliers(@RequestParam String term) {
        return ResponseEntity.ok(inventoryService.searchSuppliers(term));
    }

    @PutMapping("/suppliers/{id}")
    @Operation(summary = "Update supplier")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SupplierResponse> updateSupplier(
            @PathVariable Long id,
            @RequestBody CreateSupplierRequest request) {
        return ResponseEntity.ok(inventoryService.updateSupplier(id, request));
    }

    @DeleteMapping("/suppliers/{id}")
    @Operation(summary = "Delete supplier")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteSupplier(@PathVariable Long id) {
        inventoryService.deleteSupplier(id);
        return ResponseEntity.noContent().build();
    }

    // ========== Purchase Orders Endpoints ==========

    @PostMapping("/purchase-orders")
    @Operation(summary = "Create purchase order")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PurchaseOrderResponse> createPurchaseOrder(@RequestBody CreatePurchaseOrderRequest request) {
        PurchaseOrderResponse response = inventoryService.createPurchaseOrder(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping("/purchase-orders")
    @Operation(summary = "Get all purchase orders")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PurchaseOrderResponse>> getAllPurchaseOrders(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getAllPurchaseOrders(hotelId));
    }

    @GetMapping("/purchase-orders/{id}")
    @Operation(summary = "Get purchase order by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PurchaseOrderResponse> getPurchaseOrderById(@PathVariable Long id) {
        return ResponseEntity.ok(inventoryService.getPurchaseOrderById(id));
    }

    @GetMapping("/purchase-orders/number/{poNumber}")
    @Operation(summary = "Get purchase order by number")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PurchaseOrderResponse> getPurchaseOrderByNumber(@PathVariable String poNumber) {
        return ResponseEntity.ok(inventoryService.getPurchaseOrderByNumber(poNumber));
    }

    @GetMapping("/purchase-orders/supplier/{supplierId}")
    @Operation(summary = "Get purchase orders by supplier")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PurchaseOrderResponse>> getPurchaseOrdersBySupplier(@PathVariable Long supplierId) {
        return ResponseEntity.ok(inventoryService.getPurchaseOrdersBySupplier(supplierId));
    }

    @GetMapping("/purchase-orders/status/{status}")
    @Operation(summary = "Get purchase orders by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PurchaseOrderResponse>> getPurchaseOrdersByStatus(
            @RequestParam(required = false) Long hotelId,
            @PathVariable String status) {
        return ResponseEntity.ok(inventoryService.getPurchaseOrdersByStatus(hotelId, status));
    }

    @GetMapping("/purchase-orders/pending-deliveries")
    @Operation(summary = "Get pending deliveries")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PurchaseOrderResponse>> getPendingDeliveries(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getPendingDeliveries(hotelId));
    }

    @PostMapping("/purchase-orders/{id}/approve")
    @Operation(summary = "Approve purchase order")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PurchaseOrderResponse> approvePurchaseOrder(
            @PathVariable Long id,
            @RequestParam String approvedBy) {
        return ResponseEntity.ok(inventoryService.approvePurchaseOrder(id, approvedBy));
    }

    @PostMapping("/purchase-orders/{id}/receive")
    @Operation(summary = "Receive purchase order")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PurchaseOrderResponse> receivePurchaseOrder(
            @PathVariable Long id,
            @RequestBody ReceivePurchaseOrderRequest request) {
        return ResponseEntity.ok(inventoryService.receivePurchaseOrder(id, request));
    }

    @PostMapping("/purchase-orders/{id}/cancel")
    @Operation(summary = "Cancel purchase order")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PurchaseOrderResponse> cancelPurchaseOrder(
            @PathVariable Long id,
            @RequestParam String reason) {
        return ResponseEntity.ok(inventoryService.cancelPurchaseOrder(id, reason));
    }

    // ========== Stock Transactions Endpoints ==========

    @GetMapping("/transactions")
    @Operation(summary = "Get stock transactions")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<StockTransactionResponse>> getStockTransactions(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(inventoryService.getStockTransactions(hotelId, startDate, endDate));
    }

    @GetMapping("/items/{itemId}/transactions")
    @Operation(summary = "Get item stock history")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<StockTransactionResponse>> getItemStockHistory(@PathVariable Long itemId) {
        return ResponseEntity.ok(inventoryService.getItemStockHistory(itemId));
    }

    // ========== Reports Endpoints ==========

    @GetMapping("/reports/total-value")
    @Operation(summary = "Get total inventory value")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Double> getTotalInventoryValue(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getTotalInventoryValue(hotelId));
    }

    @GetMapping("/reports/total-count")
    @Operation(summary = "Get total items count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Integer> getTotalItemsCount(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getTotalItemsCount(hotelId));
    }

    @GetMapping("/reports/low-stock-count")
    @Operation(summary = "Get low stock count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Integer> getLowStockCount(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(inventoryService.getLowStockCount(hotelId));
    }
}