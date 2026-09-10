package com.periferia.prueba.util;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

/**
 * Deserializador flexible para campos LocalDateTime que pueden llegar desde
 * el cliente como fecha completa ISO ("2026-08-20T00:00:00") o solo fecha
 * ("2026-08-20"). En el segundo caso se asume hora 00:00:00.
 *
 * Motivo: @JsonFormat(pattern = "yyyy-MM-dd") sobre un LocalDateTime falla en
 * deserialización porque el TemporalAccessor resultante no trae hora/minuto,
 * y LocalDateTime.from(...) los exige. Este deserializador evita ese
 * problema intentando primero el formato completo y usando LocalDate como
 * fallback.
 */
public class FlexibleLocalDateTimeDeserializer extends JsonDeserializer<LocalDateTime> {

    @Override
    public LocalDateTime deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        String value = p.getText();
        if (value == null || value.isBlank()) {
            return null;
        }
        value = value.trim();
        try {
            return LocalDateTime.parse(value);
        } catch (DateTimeParseException e) {
            return LocalDate.parse(value).atStartOfDay();
        }
    }
}
