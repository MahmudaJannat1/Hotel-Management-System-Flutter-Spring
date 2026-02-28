package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.inventory.*;
import com.spring.hotel_management_backend.model.dto.response.admin.inventory.*;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.admin.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements InventoryService {

    private final InventoryRepository inventoryRepository;
    private final SupplierRepository supplierRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final StockTransactionRepository stockTransactionRepository;
    private final UserRepository userRepository;

    // ========== Helper Methods ==========

    private String generatePONumber() {
        return "PO" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }

    private String getCurrentUser() {
        // In real app, get from SecurityContext
        return "SYSTEM";
    }

    private String getItemStatus(Inventory item) {
        if (item.getQuantity() <= 0) {
            return "OUT_OF_STOCK";
        } else if (item.getQuantity() <= item.getReorderLevel()) {
            return "LOW_STOCK";
        } else if (item.getExpiryDate() != null &&
                item.getExpiryDate().isBefore(LocalDate.now().plusDays(30))) {
            return "EXPIRING_SOON";
        }
        return "NORMAL";
    }

    // ========== Inventory Items Implementation ==========

    @Override
    @Transactional
    public InventoryItemResponse createInventoryItem(CreateInventoryItemRequest request) {
        Inventory item = new Inventory();
        item.setItemName(request.getItemName());
        item.setItemCode(request.getItemCode());
        item.setCategory(request.getCategory());
        item.setSubCategory(request.getSubCategory());
        item.setDescription(request.getDescription());
        item.setQuantity(request.getQuantity() != null ? request.getQuantity() : 0);
        item.setUnit(request.getUnit());
        item.setUnitPrice(request.getUnitPrice());
        item.setReorderLevel(request.getReorderLevel());
        item.setMaximumLevel(request.getMaximumLevel());
        item.setLocation(request.getLocation());
        item.setSupplier(request.getSupplier());
        item.setSupplierId(request.getSupplierId());
        item.setBrand(request.getBrand());
        item.setSpecifications(request.getSpecifications());
        item.setImageUrl(request.getImageUrl());
        item.setBarcode(request.getBarcode());
        item.setExpiryDate(request.getExpiryDate());
        item.setBatchNo(request.getBatchNo());
        item.setNotes(request.getNotes());
        item.setHotelId(request.getHotelId());
        item.setIsActive(true);

        Inventory savedItem = inventoryRepository.save(item);

        // Create initial stock transaction
        if (request.getQuantity() != null && request.getQuantity() > 0) {
            createStockTransaction(savedItem, "INITIAL", request.getQuantity(),
                    request.getUnitPrice(), "Initial stock setup", null);
        }

        return mapToInventoryItemResponse(savedItem);
    }

    @Override
    public List<InventoryItemResponse> getAllInventoryItems(Long hotelId) {
        List<Inventory> items;
        if (hotelId != null) {
            items = inventoryRepository.findByHotelId(hotelId);
        } else {
            items = inventoryRepository.findAll();
        }
        return items.stream()
                .map(this::mapToInventoryItemResponse)
                .collect(Collectors.toList());
    }

    @Override
    public InventoryItemResponse getInventoryItemById(Long id) {
        Inventory item = inventoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inventory item not found with id: " + id));
        return mapToInventoryItemResponse(item);
    }

    @Override
    public List<InventoryItemResponse> getInventoryItemsByCategory(Long hotelId, String category) {
        return inventoryRepository.findByHotelIdAndCategory(hotelId, category)
                .stream()
                .map(this::mapToInventoryItemResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<InventoryItemResponse> getLowStockItems(Long hotelId) {
        return inventoryRepository.findLowStockItems()
                .stream()
                .filter(item -> hotelId == null || item.getHotelId().equals(hotelId))
                .map(this::mapToInventoryItemResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<InventoryItemResponse> getExpiringItems(Long hotelId, Integer days) {
        LocalDate expiryThreshold = LocalDate.now().plusDays(days);
        return inventoryRepository.findAll()
                .stream()
                .filter(item -> item.getExpiryDate() != null &&
                        item.getExpiryDate().isBefore(expiryThreshold) &&
                        (hotelId == null || item.getHotelId().equals(hotelId)))
                .map(this::mapToInventoryItemResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public InventoryItemResponse updateInventoryItem(Long id, UpdateInventoryItemRequest request) {
        Inventory item = inventoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inventory item not found with id: " + id));

        item.setItemName(request.getItemName());
        item.setItemCode(request.getItemCode());
        item.setCategory(request.getCategory());
        item.setSubCategory(request.getSubCategory());
        item.setDescription(request.getDescription());
        item.setQuantity(request.getQuantity());  
        item.setUnit(request.getUnit());
        item.setUnitPrice(request.getUnitPrice());
        item.setReorderLevel(request.getReorderLevel());
        item.setMaximumLevel(request.getMaximumLevel());
        item.setLocation(request.getLocation());
        item.setSupplier(request.getSupplier());
        item.setSupplierId(request.getSupplierId());
        item.setBrand(request.getBrand());
        item.setSpecifications(request.getSpecifications());
        item.setImageUrl(request.getImageUrl());
        item.setBarcode(request.getBarcode());
        item.setExpiryDate(request.getExpiryDate());
        item.setBatchNo(request.getBatchNo());
        item.setNotes(request.getNotes());
        item.setIsActive(request.getIsActive());

        Inventory updatedItem = inventoryRepository.save(item);
        return mapToInventoryItemResponse(updatedItem);
    }

    @Override
    @Transactional
    public InventoryItemResponse adjustStock(Long id, StockAdjustRequest request) {
        Inventory item = inventoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inventory item not found with id: " + id));

        Integer oldQuantity = item.getQuantity();
        Integer newQuantity = request.getNewQuantity();
        Integer changeAmount = newQuantity - oldQuantity;

        item.setQuantity(newQuantity);
        Inventory updatedItem = inventoryRepository.save(item);

        // Record transaction
        createStockTransaction(updatedItem, "ADJUSTMENT", changeAmount,
                item.getUnitPrice(), request.getReason(), request.getReference());

        return mapToInventoryItemResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteInventoryItem(Long id) {
        if (!inventoryRepository.existsById(id)) {
            throw new RuntimeException("Inventory item not found with id: " + id);
        }
        inventoryRepository.deleteById(id);
    }

    // ========== Suppliers Implementation ==========

    @Override
    @Transactional
    public SupplierResponse createSupplier(CreateSupplierRequest request) {
        if (supplierRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Supplier with email " + request.getEmail() + " already exists");
        }

        Supplier supplier = new Supplier();
        supplier.setName(request.getName());
        supplier.setContactPerson(request.getContactPerson());
        supplier.setEmail(request.getEmail());
        supplier.setPhone(request.getPhone());
        supplier.setAddress(request.getAddress());
        supplier.setCity(request.getCity());
        supplier.setCountry(request.getCountry());
        supplier.setPaymentTerms(request.getPaymentTerms());
        supplier.setTaxId(request.getTaxId());
        supplier.setWebsite(request.getWebsite());
        supplier.setNotes(request.getNotes());
        supplier.setHotelId(request.getHotelId());
        supplier.setIsActive(true);

        Supplier savedSupplier = supplierRepository.save(supplier);
        return mapToSupplierResponse(savedSupplier);
    }

    @Override
    public List<SupplierResponse> getAllSuppliers(Long hotelId) {
        List<Supplier> suppliers;
        if (hotelId != null) {
            suppliers = supplierRepository.findByHotelId(hotelId);
        } else {
            suppliers = supplierRepository.findAll();
        }
        return suppliers.stream()
                .map(this::mapToSupplierResponse)
                .collect(Collectors.toList());
    }

    @Override
    public SupplierResponse getSupplierById(Long id) {
        Supplier supplier = supplierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Supplier not found with id: " + id));
        return mapToSupplierResponse(supplier);
    }

    @Override
    public List<SupplierResponse> searchSuppliers(String searchTerm) {
        return supplierRepository.searchSuppliers(searchTerm)
                .stream()
                .map(this::mapToSupplierResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public SupplierResponse updateSupplier(Long id, CreateSupplierRequest request) {
        Supplier supplier = supplierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Supplier not found with id: " + id));

        supplier.setName(request.getName());
        supplier.setContactPerson(request.getContactPerson());
        supplier.setEmail(request.getEmail());
        supplier.setPhone(request.getPhone());
        supplier.setAddress(request.getAddress());
        supplier.setCity(request.getCity());
        supplier.setCountry(request.getCountry());
        supplier.setPaymentTerms(request.getPaymentTerms());
        supplier.setTaxId(request.getTaxId());
        supplier.setWebsite(request.getWebsite());
        supplier.setNotes(request.getNotes());

        Supplier updatedSupplier = supplierRepository.save(supplier);
        return mapToSupplierResponse(updatedSupplier);
    }

    @Override
    @Transactional
    public void deleteSupplier(Long id) {
        if (!supplierRepository.existsById(id)) {
            throw new RuntimeException("Supplier not found with id: " + id);
        }
        supplierRepository.deleteById(id);
    }

    // ========== Purchase Orders Implementation ==========

    @Override
    @Transactional
    public PurchaseOrderResponse createPurchaseOrder(CreatePurchaseOrderRequest request) {
        Supplier supplier = supplierRepository.findById(request.getSupplierId())
                .orElseThrow(() -> new RuntimeException("Supplier not found with id: " + request.getSupplierId()));

        PurchaseOrder po = new PurchaseOrder();
        po.setPoNumber(generatePONumber());
        po.setSupplier(supplier);
        po.setOrderDate(LocalDate.now());
        po.setExpectedDeliveryDate(request.getExpectedDeliveryDate());
        po.setStatus("PENDING");
        po.setPaymentStatus("PENDING");
        po.setTaxAmount(request.getTaxAmount());
        po.setDiscountAmount(request.getDiscountAmount());
        po.setPaymentTerms(request.getPaymentTerms());
        po.setNotes(request.getNotes());
        po.setCreatedBy(getCurrentUser());
        po.setHotelId(request.getHotelId());

        double subtotal = 0.0;
        for (CreatePurchaseOrderRequest.PurchaseOrderItemRequest itemReq : request.getItems()) {
            Inventory item = inventoryRepository.findById(itemReq.getInventoryItemId())
                    .orElseThrow(() -> new RuntimeException("Inventory item not found"));

            PurchaseOrderItem poItem = new PurchaseOrderItem();
            poItem.setInventoryItem(item);
            poItem.setOrderedQuantity(itemReq.getOrderedQuantity());
            poItem.setReceivedQuantity(0);
            poItem.setUnitPrice(itemReq.getUnitPrice());
            poItem.setTotalPrice(itemReq.getOrderedQuantity() * itemReq.getUnitPrice());
            poItem.setUnit(item.getUnit());
            poItem.setStatus("PENDING");
            poItem.setPurchaseOrder(po);

            po.getItems().add(poItem);
            subtotal += poItem.getTotalPrice();
        }

        po.setSubtotal(subtotal);
        po.setTotalAmount(subtotal + request.getTaxAmount() - request.getDiscountAmount());

        PurchaseOrder savedPO = purchaseOrderRepository.save(po);
        return mapToPurchaseOrderResponse(savedPO);
    }

    @Override
    public List<PurchaseOrderResponse> getAllPurchaseOrders(Long hotelId) {
        List<PurchaseOrder> pos;
        if (hotelId != null) {
            pos = purchaseOrderRepository.findByHotelId(hotelId);
        } else {
            pos = purchaseOrderRepository.findAll();
        }
        return pos.stream()
                .map(this::mapToPurchaseOrderResponse)
                .collect(Collectors.toList());
    }

    @Override
    public PurchaseOrderResponse getPurchaseOrderById(Long id) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase order not found with id: " + id));
        return mapToPurchaseOrderResponse(po);
    }

    @Override
    public PurchaseOrderResponse getPurchaseOrderByNumber(String poNumber) {
        PurchaseOrder po = purchaseOrderRepository.findByPoNumber(poNumber)
                .orElseThrow(() -> new RuntimeException("Purchase order not found with number: " + poNumber));
        return mapToPurchaseOrderResponse(po);
    }

    @Override
    public List<PurchaseOrderResponse> getPurchaseOrdersBySupplier(Long supplierId) {
        return purchaseOrderRepository.findBySupplierId(supplierId)
                .stream()
                .map(this::mapToPurchaseOrderResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PurchaseOrderResponse> getPurchaseOrdersByStatus(Long hotelId, String status) {
        return purchaseOrderRepository.findByStatus(status)
                .stream()
                .filter(po -> hotelId == null || po.getHotelId().equals(hotelId))
                .map(this::mapToPurchaseOrderResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PurchaseOrderResponse> getPendingDeliveries(Long hotelId) {
        return purchaseOrderRepository.findPendingDeliveries(LocalDate.now())
                .stream()
                .filter(po -> hotelId == null || po.getHotelId().equals(hotelId))
                .map(this::mapToPurchaseOrderResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public PurchaseOrderResponse approvePurchaseOrder(Long id, String approvedBy) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase order not found with id: " + id));

        po.setStatus("APPROVED");
        po.setApprovedBy(approvedBy);
        po.setApprovedDate(LocalDate.now());

        PurchaseOrder updatedPO = purchaseOrderRepository.save(po);
        return mapToPurchaseOrderResponse(updatedPO);
    }

    @Override
    @Transactional
    public PurchaseOrderResponse receivePurchaseOrder(Long id, ReceivePurchaseOrderRequest request) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase order not found with id: " + id));

        boolean partiallyReceived = false;

        for (ReceivePurchaseOrderRequest.ReceivedItem receivedItem : request.getReceivedItems()) {
            PurchaseOrderItem poItem = po.getItems().stream()
                    .filter(item -> item.getId().equals(receivedItem.getPurchaseOrderItemId()))
                    .findFirst()
                    .orElseThrow(() -> new RuntimeException("Purchase order item not found"));

            int newReceived = poItem.getReceivedQuantity() + receivedItem.getReceivedQuantity();

            if (newReceived > poItem.getOrderedQuantity()) {
                throw new RuntimeException("Received quantity cannot exceed ordered quantity for item");
            }

            poItem.setReceivedQuantity(newReceived);

            if (newReceived < poItem.getOrderedQuantity()) {
                partiallyReceived = true;
                poItem.setStatus("PARTIALLY_RECEIVED");
            } else if (newReceived == poItem.getOrderedQuantity()) {  // Fixed: use == for int
                poItem.setStatus("RECEIVED");
            }

            // Update inventory
            Inventory item = poItem.getInventoryItem();
            int newQty = item.getQuantity() + receivedItem.getReceivedQuantity();
            item.setQuantity(newQty);
            inventoryRepository.save(item);

            // Record transaction
            createStockTransaction(item, "PURCHASE", receivedItem.getReceivedQuantity(),
                    poItem.getUnitPrice(), "Purchase Order: " + po.getPoNumber(),
                    po.getPoNumber());
        }

        po.setStatus(partiallyReceived ? "PARTIALLY_RECEIVED" : "COMPLETED");
        po.setReceivedDate(LocalDate.now());

        PurchaseOrder updatedPO = purchaseOrderRepository.save(po);
        return mapToPurchaseOrderResponse(updatedPO);
    }

    @Override
    @Transactional
    public PurchaseOrderResponse cancelPurchaseOrder(Long id, String reason) {
        PurchaseOrder po = purchaseOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase order not found with id: " + id));

        po.setStatus("CANCELLED");
        po.setNotes(po.getNotes() + " [CANCELLED: " + reason + "]");

        PurchaseOrder updatedPO = purchaseOrderRepository.save(po);
        return mapToPurchaseOrderResponse(updatedPO);
    }

    // ========== Stock Transactions Implementation ==========

    @Override
    public List<StockTransactionResponse> getStockTransactions(Long hotelId, LocalDate startDate, LocalDate endDate) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        return stockTransactionRepository.findByDateRange(startDateTime, endDateTime)
                .stream()
                .filter(txn -> hotelId == null || txn.getHotelId().equals(hotelId))
                .map(this::mapToStockTransactionResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<StockTransactionResponse> getItemStockHistory(Long itemId) {
        return stockTransactionRepository.findByInventoryItemId(itemId)
                .stream()
                .map(this::mapToStockTransactionResponse)
                .collect(Collectors.toList());
    }

    // ========== Reports & Analytics ==========

    @Override
    public Double getTotalInventoryValue(Long hotelId) {
        if (hotelId != null) {
            return inventoryRepository.getTotalInventoryValue(hotelId);
        }
        return inventoryRepository.findAll().stream()
                .mapToDouble(item -> item.getQuantity() * item.getUnitPrice())
                .sum();
    }

    @Override
    public Integer getTotalItemsCount(Long hotelId) {
        if (hotelId != null) {
            return inventoryRepository.findByHotelId(hotelId).size();
        }
        return (int) inventoryRepository.count();
    }

    @Override
    public Integer getLowStockCount(Long hotelId) {
        return (int) inventoryRepository.findLowStockItems()
                .stream()
                .filter(item -> hotelId == null || item.getHotelId().equals(hotelId))
                .count();
    }

    // ========== Private Helper Methods ==========

    private void createStockTransaction(Inventory item, String type, int quantity,
                                        Double unitPrice, String reason, String reference) {
        StockTransaction txn = new StockTransaction();
        txn.setInventoryItem(item);
        txn.setTransactionType(type);
        txn.setQuantity(quantity);
        txn.setUnitPrice(unitPrice);
        txn.setTotalPrice(Math.abs(quantity) * unitPrice);
        txn.setPreviousQuantity(item.getQuantity() - quantity);
        txn.setNewQuantity(item.getQuantity());
        // txn.setChangeAmount(quantity);  // Remove if not in entity
        txn.setReason(reason);
        txn.setReference(reference);
        txn.setPerformedBy(getCurrentUser());
        txn.setTransactionDate(LocalDateTime.now());
        txn.setHotelId(item.getHotelId());

        stockTransactionRepository.save(txn);
    }

    private InventoryItemResponse mapToInventoryItemResponse(Inventory item) {
        String supplierName = null;
        if (item.getSupplierId() != null) {
            Optional<Supplier> supplier = supplierRepository.findById(item.getSupplierId());
            if (supplier.isPresent()) {
                supplierName = supplier.get().getName();
            }
        }

        return InventoryItemResponse.builder()
                .id(item.getId())
                .itemName(item.getItemName())
                .itemCode(item.getItemCode())
                .category(item.getCategory())
                .subCategory(item.getSubCategory())
                .description(item.getDescription())
                .quantity(item.getQuantity())
                .unit(item.getUnit())
                .unitPrice(item.getUnitPrice())
                .totalValue(item.getQuantity() * item.getUnitPrice())
                .reorderLevel(item.getReorderLevel())
                .maximumLevel(item.getMaximumLevel())
                .location(item.getLocation())
                .supplier(item.getSupplier())
                .supplierId(item.getSupplierId())
                .supplierName(supplierName)
                .brand(item.getBrand())
                .specifications(item.getSpecifications())
                .imageUrl(item.getImageUrl())
                .barcode(item.getBarcode())
                .isActive(item.getIsActive())
                .expiryDate(item.getExpiryDate())
                .batchNo(item.getBatchNo())
                .notes(item.getNotes())
                .hotelId(item.getHotelId())
                .status(getItemStatus(item))
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }

    private SupplierResponse mapToSupplierResponse(Supplier supplier) {
        List<PurchaseOrder> pos = purchaseOrderRepository.findBySupplierId(supplier.getId());
        int totalPOs = pos.size();
        double totalValue = pos.stream()
                .filter(po -> "COMPLETED".equals(po.getStatus()))
                .mapToDouble(PurchaseOrder::getTotalAmount)
                .sum();

        return SupplierResponse.builder()
                .id(supplier.getId())
                .name(supplier.getName())
                .contactPerson(supplier.getContactPerson())
                .email(supplier.getEmail())
                .phone(supplier.getPhone())
                .address(supplier.getAddress())
                .city(supplier.getCity())
                .country(supplier.getCountry())
                .paymentTerms(supplier.getPaymentTerms())
                .taxId(supplier.getTaxId())
                .website(supplier.getWebsite())
                .notes(supplier.getNotes())
                .isActive(supplier.getIsActive())
                .hotelId(supplier.getHotelId())
                .totalPurchaseOrders(totalPOs)
                .totalPurchaseValue(totalValue)
                .createdAt(supplier.getCreatedAt())
                .updatedAt(supplier.getUpdatedAt())
                .build();
    }

    private PurchaseOrderResponse mapToPurchaseOrderResponse(PurchaseOrder po) {
        List<PurchaseOrderResponse.PurchaseOrderItemResponse> itemResponses = po.getItems().stream()
                .map(item -> PurchaseOrderResponse.PurchaseOrderItemResponse.builder()
                        .id(item.getId())
                        .inventoryItemId(item.getInventoryItem().getId())
                        .itemName(item.getInventoryItem().getItemName())
                        .itemCode(item.getInventoryItem().getItemCode())
                        .unit(item.getUnit())
                        .orderedQuantity(item.getOrderedQuantity())
                        .receivedQuantity(item.getReceivedQuantity())
                        .pendingQuantity(item.getOrderedQuantity() - item.getReceivedQuantity())
                        .unitPrice(item.getUnitPrice())
                        .totalPrice(item.getTotalPrice())
                        .status(item.getStatus())
                        .build())
                .collect(Collectors.toList());

        return PurchaseOrderResponse.builder()
                .id(po.getId())
                .poNumber(po.getPoNumber())
                .supplierId(po.getSupplier().getId())
                .supplierName(po.getSupplier().getName())
                .supplierContact(po.getSupplier().getContactPerson())
                .supplierPhone(po.getSupplier().getPhone())
                .orderDate(po.getOrderDate())
                .expectedDeliveryDate(po.getExpectedDeliveryDate())
                .receivedDate(po.getReceivedDate())
                .status(po.getStatus())
                .paymentStatus(po.getPaymentStatus())
                .subtotal(po.getSubtotal())
                .taxAmount(po.getTaxAmount())
                .discountAmount(po.getDiscountAmount())
                .totalAmount(po.getTotalAmount())
                .paymentTerms(po.getPaymentTerms())
                .notes(po.getNotes())
                .createdBy(po.getCreatedBy())
                .approvedBy(po.getApprovedBy())
                .approvedDate(po.getApprovedDate())
                .items(itemResponses)
                .hotelId(po.getHotelId())
                .createdAt(po.getCreatedAt())
                .updatedAt(po.getUpdatedAt())
                .build();
    }

    private StockTransactionResponse mapToStockTransactionResponse(StockTransaction txn) {
        return StockTransactionResponse.builder()
                .id(txn.getId())
                .inventoryItemId(txn.getInventoryItem().getId())
                .itemName(txn.getInventoryItem().getItemName())
                .itemCode(txn.getInventoryItem().getItemCode())
                .transactionType(txn.getTransactionType())
                .quantity(txn.getQuantity())
                .unitPrice(txn.getUnitPrice())
                .totalPrice(txn.getTotalPrice())
                .previousQuantity(txn.getPreviousQuantity())
                .newQuantity(txn.getNewQuantity())
                .changeAmount(txn.getChangeAmount())
                .reference(txn.getReference())
                .reason(txn.getReason())
                .performedBy(txn.getPerformedBy())
                .transactionDate(txn.getTransactionDate())
                .notes(txn.getNotes())
                .hotelId(txn.getHotelId())
                .build();
    }
}