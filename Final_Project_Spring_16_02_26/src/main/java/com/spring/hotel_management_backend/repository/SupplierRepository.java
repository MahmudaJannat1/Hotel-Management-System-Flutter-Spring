package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SupplierRepository extends JpaRepository<Supplier, Long> {

    Optional<Supplier> findByEmail(String email);

    List<Supplier> findByHotelId(Long hotelId);

    List<Supplier> findByIsActiveTrue();

    @Query("SELECT s FROM Supplier s WHERE LOWER(s.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(s.contactPerson) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<Supplier> searchSuppliers(@Param("searchTerm") String searchTerm);

    List<Supplier> findByCity(String city);

    boolean existsByEmail(String email);
}