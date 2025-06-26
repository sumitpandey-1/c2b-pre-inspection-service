package com.cars24.c2b_pre_inspection_service.api.internal.controller.health;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<String> health(){
        return ResponseEntity.ok("Success");
    }
}
