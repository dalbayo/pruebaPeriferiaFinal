package com.periferia.prueba.model;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.periferia.prueba.util.FlexibleLocalDateTimeDeserializer;
import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "publicacion")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Publicacion implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false, foreignKey = @ForeignKey(name = "fk_publicacion_usuario"))
    private Usuario usuario;

    @ManyToOne
    @JoinColumn(name = "categoria_id", foreignKey = @ForeignKey(name = "fk_publicacion_categoria"))
    private Categoria categoria;

    @Column(nullable = false, length = 255)
    private String titulo;

    @Column(nullable = false, unique = true, length = 255)
    private String slug;

    @Column(columnDefinition = "TEXT")
    private String resumen;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String contenido;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "smallint DEFAULT 0")
    private Short estado = 0;

    @Column(name = "fecha_publicacion")
    @JsonDeserialize(using = FlexibleLocalDateTimeDeserializer.class)
    private LocalDateTime fechaPublicacion;

    @Builder.Default
    @Column(name = "creado_en", nullable = false, columnDefinition = "timestamp DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime creadoEn = LocalDateTime.now();

    @Builder.Default
    @Column(name = "actualizado_en", nullable = false, columnDefinition = "timestamp DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime actualizadoEn = LocalDateTime.now();

    @Builder.Default
    @Column(nullable = false, columnDefinition = "smallint DEFAULT 1")
    private Short eliminado = 1;
}
