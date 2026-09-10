# ============================================
# CONFIGURACIÓN BASE
# ============================================
$basePackage = "com.periferia.prueba"
$basePath = "src/main/java/com/periferia/prueba"

$modelPath = "$basePath/model"
$repoPath = "$basePath/repository"
$servicePath = "$basePath/service"
$implPath = "$basePath/service/impl"

# ============================================
# LISTA DE TABLAS
# ============================================
$tables = @(
    "pais",
    "empleado",
    "departamento",
    "cargo",
    "ciudad",
    "area_trabajo",
    "usuario_perfil",
    "dispositivo",
    "usuario",
    "perfil",
    "turno_real",
    "jornada_laboral",
    "marcacion_inconsistencia",
    "marcacion",
    "historial_sincronizacion_sap",
    "auditoria_eventos",
    "historial_cambios_turno",
    "alerta_operativa_empleado",
    "alerta_operativa",
    "empleado_supervisor",
    "carga_sap",
    "estado_carga_sap",
    "estado_marcacion",
    "log_sistema",
    "turno_programado",
    "sincronizacion_apps",
    "parametro_sistema",
    "tipo_carga_sap"
)

# ============================================
# ELIMINAR CARPETAS ANTERIORES
# ============================================
Write-Host "Eliminando capas anteriores..."

if (Test-Path $modelPath) { Remove-Item $modelPath -Recurse -Force }
if (Test-Path $repoPath) { Remove-Item $repoPath -Recurse -Force }
if (Test-Path $servicePath) { Remove-Item $servicePath -Recurse -Force }

# ============================================
# RECREAR DIRECTORIOS
# ============================================
Write-Host "Creando nueva estructura..."

New-Item -ItemType Directory -Force -Path $modelPath | Out-Null
New-Item -ItemType Directory -Force -Path $repoPath | Out-Null
New-Item -ItemType Directory -Force -Path $servicePath | Out-Null
New-Item -ItemType Directory -Force -Path $implPath | Out-Null

# ============================================
# FUNCIÓN snake_case → PascalCase
# ============================================
function To-PascalCase($text) {
    $parts = $text -split "_"
    $result = ""

    foreach ($part in $parts) {
        if ($part.Length -gt 0) {
            $result += $part.Substring(0, 1).ToUpper() + $part.Substring(1).ToLower()
        }
    }

    return $result
}

# ============================================
# GENERACIÓN
# ============================================
foreach ($table in $tables) {

    $className = To-PascalCase $table
    Write-Host "Generando: $className"

    # ============================
    # MODEL (ENTITY JPA)
    # ============================
    $modelContent = @"
package $basePackage.model;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "$table")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class $className implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
"@

    $modelContent | Out-File "$modelPath/$className.java" -Encoding utf8

    # ============================
    # REPOSITORY
    # ============================
    $repoContent = @"
package $basePackage.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import $basePackage.model.$className;

@Repository
public interface ${className}Repository extends JpaRepository<$className, Long> {
}
"@

    $repoContent | Out-File "$repoPath/${className}Repository.java" -Encoding utf8

    # ============================
    # SERVICE INTERFACE
    # ============================
    $serviceContent = @"
package $basePackage.service;

import java.util.List;
import $basePackage.model.$className;

public interface ${className}Service {

    List<$className> findAll();
    $className findById(Long id);
    $className save($className entity);
    void delete(Long id);
}
"@

    $serviceContent | Out-File "$servicePath/${className}Service.java" -Encoding utf8

    # ============================
    # SERVICE IMPLEMENTATION
    # ============================
    $implContent = @"
package $basePackage.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import $basePackage.model.$className;
import $basePackage.repository.${className}Repository;
import $basePackage.service.${className}Service;

@Service
@RequiredArgsConstructor
public class ${className}ServiceImpl implements ${className}Service {

    private final ${className}Repository repository;

    @Override
    public List<$className> findAll() {
        return repository.findAll();
    }

    @Override
    public $className findById(Long id) {
        return repository.findById(id).orElse(null);
    }

    @Override
    public $className save($className entity) {
        return repository.save(entity);
    }

    @Override
    public void delete(Long id) {
        repository.deleteById(id);
    }
}
"@

    $implContent | Out-File "$implPath/${className}ServiceImpl.java" -Encoding utf8
}

Write-Host ""
Write-Host "======================================="
Write-Host "GENERACIÓN COMPLETADA CORRECTAMENTE"
Write-Host "======================================="
Write-Host ""
