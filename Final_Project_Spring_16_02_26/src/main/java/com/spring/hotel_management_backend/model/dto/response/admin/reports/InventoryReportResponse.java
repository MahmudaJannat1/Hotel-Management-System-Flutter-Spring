package com.spring.hotel_management_backend.model.dto.response.admin.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InventoryReportResponse {

    private String reportType;
    private LocalDate asOfDate;
    private String generatedAt;

    // Summary
    private Integer totalItems;
    private Integer lowStockItems;
    private Integer outOfStockItems;
    private Double totalInventoryValue;

    // Category wise
    private Map<String, CategoryInventory> categoryStats;

    // Low stock items
    private List<LowStockItem> lowStockItemsList;

    // Recent transactions
    private List<InventoryTransaction> recentTransactions;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CategoryInventory {
        private String category;
        private Integer itemCount;
        private Integer totalQuantity;
        private Double totalValue;
        private Integer lowStockCount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LowStockItem {
        private Long itemId;
        private String itemName;
        private String category;
        private Integer currentQuantity;
        private Integer reorderLevel;
        private String unit;
        private String supplier;
        private String status; // LOW_STOCK, CRITICAL, OUT_OF_STOCK
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InventoryTransaction {
        private LocalDate date;
        private String itemName;
        private String transactionType; // PURCHASE, CONSUMPTION, RETURN
        private Integer quantity;
        private Double unitPrice;
        private Double totalPrice;
        private String supplier;
    }
}