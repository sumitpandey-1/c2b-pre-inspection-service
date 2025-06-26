package com.cars24.c2b_pre_inspection_service.shared;

/**
 * Generic response DTO
 * This can be used by all modules for standardized responses
 */
public class ResponseDto<T> {
    private boolean success;
    private String message;
    private T data;
    
    public ResponseDto() {}
    
    public ResponseDto(boolean success, String message, T data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }
    
    // Static factory methods
    public static <T> ResponseDto<T> success(T data) {
        return new ResponseDto<>(true, "Success", data);
    }
    
    public static <T> ResponseDto<T> error(String message) {
        return new ResponseDto<>(false, message, null);
    }
    
    // Getters and Setters
    public boolean isSuccess() {
        return success;
    }
    
    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public T getData() {
        return data;
    }
    
    public void setData(T data) {
        this.data = data;
    }
} 