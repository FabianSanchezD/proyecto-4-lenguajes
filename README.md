# Sistema de Gestión de la Copa Mundial FIFA 2026

Aplicación web desarrollada con **Ruby on Rails 7.1** y **SQLite** para gestionar
la Copa Mundial de la FIFA México–USA–Canadá 2026: 48 selecciones, 12 grupos de
4 equipos, cálculo automático de la tabla de posiciones, determinación de
clasificados y administración completa de la fase de eliminación directa hasta
el campeón.

Proyecto 4 - Programación Orientada a Objetos (POO).

---

## Tecnologías

- **Ruby** 3.3.11
- **Ruby on Rails** 7.1
- **SQLite 3** (base de datos relacional)
- **Tailwind CSS** (interfaz gráfica)

---

## Requisitos previos

- Ruby 3.3.x (se recomienda instalarlo con [rbenv](https://github.com/rbenv/rbenv))
- Bundler (`gem install bundler`)
- SQLite 3

En macOS con Homebrew:

```bash
brew install rbenv ruby-build sqlite
rbenv install 3.3.11
rbenv local 3.3.11
gem install bundler
```

---

## Pasos de instalación

```bash
# 1. Clonar el repositorio
git clone <URL-DEL-REPOSITORIO>
cd proyecto-4-lenguajes

# 2. Instalar las dependencias (gemas)
bundle install

# 3. Crear y migrar la base de datos SQLite
bin/rails db:create
bin/rails db:migrate

# 4. Cargar los datos iniciales (12 grupos, 48 selecciones y sus calendarios)
bin/rails db:seed

# 5. Iniciar la aplicación
bin/dev          # compila Tailwind y levanta el servidor
# (alternativa sin watcher de CSS)
bin/rails tailwindcss:build && bin/rails server
```

Abrir el navegador en **http://localhost:3000**.

---

## Manual de usuario

La barra superior permite navegar entre las secciones del sistema.

### 1. Inicio (Panel)
Muestra el resumen del torneo: cantidad de grupos y selecciones, avance de la
fase de grupos, si el bracket ya fue generado y el **podio final** (campeón,
subcampeón y tercer lugar) una vez disputada la final.

### 2. Sorteo
- Muestra los **4 bombos** y la composición de los grupos.
- Botón **"Sortear grupos"**: realiza un sorteo aleatorio respetando los bombos
  (un equipo de cada bombo por grupo) y las sedes de los anfitriones
  (México → A, Canadá → B, Estados Unidos → D).
- También se puede asignar el grupo y el bombo de cada selección manualmente
  desde su edición.

### 3. Grupos
- **Crear/editar/eliminar** los 12 grupos (A a la L).
- En el detalle de cada grupo se ve la **tabla de posiciones** (calculada
  automáticamente) y la lista de partidos.
- Botón **"Generar calendario"**: crea los 6 partidos de todos-contra-todos del
  grupo (requiere que el grupo tenga 4 selecciones).

### 4. Selecciones
- **CRUD** de selecciones: nombre del país, grupo asignado, bombo, puntos, goles
  a favor y goles en contra. La diferencia de goles se calcula sola.
- Los puntos y goles se **recalculan automáticamente** al registrar resultados,
  así que normalmente no es necesario editarlos a mano.

### 5. Partidos
- Lista todos los partidos agrupados por fase (grupos y eliminación directa).
- Botón **"Registrar"/"Editar"** para capturar el marcador.
- En eliminación directa, si hay empate en el tiempo reglamentario se habilitan
  los campos de **penales** para definir al ganador.

### 6. Clasificados
- Muestra las **32 selecciones clasificadas**: 1° y 2° de cada grupo + los 8
  mejores terceros, con su procedencia (ej. `1A`, `2C`, `3F`).

### 7. Eliminación directa
- Visualiza el **bracket** completo siguiendo el **cuadro oficial del Mundial
  2026**: dieciseisavos → octavos → cuartos → semifinales → final, más el
  partido por el tercer lugar.
- El ganador de cada partido **avanza automáticamente** a la siguiente ronda.
- El bracket se **genera automáticamente** al completar la fase de grupos;
  también puede regenerarse manualmente desde esta pantalla.

### Flujo recomendado
1. Verificar grupos y selecciones (ya vienen precargados con `db:seed`).
2. Generar el calendario de cada grupo (los seeds ya lo hacen).
3. Registrar los resultados de la fase de grupos.
4. Al completar los 72 partidos de grupos, el bracket se arma solo.
5. Registrar los resultados de la eliminación directa ronda por ronda.
6. Consultar el campeón en **Inicio** o **Eliminación directa**.

---

## Arquitectura lógica

Ver el documento [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) para la
explicación del funcionamiento, los principios SOLID aplicados y el diagrama de
clases del sistema.

### Resumen
- **Modelos (ActiveRecord):** `Group`, `Team`, `Match` - solo conocen su estado.
- **Servicios (POROs) - la lógica de negocio vive aquí:**
  - `Standings::Calculator` - tabla de posiciones de un grupo.
  - `Qualification::Selector` - clasificados y los 8 mejores terceros.
  - `Knockout::BracketBuilder` - arma el cuadro oficial de eliminación directa.
  - `Knockout::ThirdPlaceAssigner` - ubica los 8 terceros en sus ranuras.
  - `Knockout::Advancer` - avanza ganadores y alimenta el tercer lugar.
  - `Knockout::Podium` - campeón, subcampeón y tercer lugar.
  - `Schedule::GroupFixtureGenerator` - calendario de fase de grupos.
  - `Draw::RandomDraw` - sorteo aleatorio por bombos.
  - `MatchResult::Recorder` - registra resultados y dispara los efectos.
- **Controladores:** delgados; delegan toda la lógica en los servicios.
