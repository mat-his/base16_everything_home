use wasm_bindgen::prelude::*;

#[wasm_bindgen]
#[derive(Clone, Copy, Debug)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

#[wasm_bindgen]
impl Color {
    #[wasm_bindgen(constructor)]
    pub fn new(r: u8, g: u8, b: u8) -> Color {
        Color { r, g, b }
    }

    #[wasm_bindgen(js_name = toHex)]
    pub fn to_hex(&self) -> String {
        format!("#{:02x}{:02x}{:02x}", self.r, self.g, self.b)
    }

    #[wasm_bindgen(js_name = fromHex)]
    pub fn from_hex(hex: &str) -> Option<Color> {
        let hex = hex.trim_start_matches('#');
        if hex.len() != 6 {
            return None;
        }
        let r = u8::from_str_radix(&hex[0..2], 16).ok()?;
        let g = u8::from_str_radix(&hex[2..4], 16).ok()?;
        let b = u8::from_str_radix(&hex[4..6], 16).ok()?;
        Some(Color { r, g, b })
    }
}

/// Calculate Euclidean distance between two colors in RGB space
fn color_distance(c1: &Color, c2: &Color) -> f64 {
    let dr = c1.r as f64 - c2.r as f64;
    let dg = c1.g as f64 - c2.g as f64;
    let db = c1.b as f64 - c2.b as f64;
    (dr * dr + dg * dg + db * db).sqrt()
}

/// Find the closest color in the palette to the given color
fn find_closest(color: &Color, palette: &[Color]) -> Color {
    let mut closest = palette[0];
    let mut min_dist = color_distance(color, &closest);

    for p in palette.iter().skip(1) {
        let dist = color_distance(color, p);
        if dist < min_dist {
            min_dist = dist;
            closest = *p;
        }
    }

    closest
}

#[wasm_bindgen]
pub struct ColorMapper {
    palette: Vec<Color>,
}

#[wasm_bindgen]
impl ColorMapper {
    #[wasm_bindgen(constructor)]
    pub fn new() -> ColorMapper {
        ColorMapper {
            palette: Vec::with_capacity(24),
        }
    }

    /// Set the base24 palette (expects 24 colors in order base00-base0F, base10-base17)
    #[wasm_bindgen(js_name = setPalette)]
    pub fn set_palette(&mut self, colors: Vec<Color>) {
        self.palette = colors;
    }

    /// Set palette from hex strings
    #[wasm_bindgen(js_name = setPaletteFromHex)]
    pub fn set_palette_from_hex(&mut self, hex_colors: Vec<String>) {
        self.palette = hex_colors
            .iter()
            .filter_map(|h| Color::from_hex(h))
            .collect();
    }

    /// Map a single color to the closest palette color
    #[wasm_bindgen(js_name = mapColor)]
    pub fn map_color(&self, r: u8, g: u8, b: u8) -> Color {
        if self.palette.is_empty() {
            return Color { r, g, b };
        }
        let color = Color { r, g, b };
        find_closest(&color, &self.palette)
    }

    /// Map a color given as hex string, returns hex string
    #[wasm_bindgen(js_name = mapColorHex)]
    pub fn map_color_hex(&self, hex: &str) -> String {
        if let Some(color) = Color::from_hex(hex) {
            self.map_color(color.r, color.g, color.b).to_hex()
        } else {
            hex.to_string()
        }
    }

    /// Batch map multiple colors for performance
    /// Input: flat array [r1, g1, b1, r2, g2, b2, ...]
    /// Output: flat array of mapped colors
    #[wasm_bindgen(js_name = mapColorsBatch)]
    pub fn map_colors_batch(&self, colors: &[u8]) -> Vec<u8> {
        if self.palette.is_empty() {
            return colors.to_vec();
        }

        let mut result = Vec::with_capacity(colors.len());
        for chunk in colors.chunks(3) {
            if chunk.len() == 3 {
                let mapped = self.map_color(chunk[0], chunk[1], chunk[2]);
                result.push(mapped.r);
                result.push(mapped.g);
                result.push(mapped.b);
            }
        }
        result
    }

    /// Batch map hex colors
    /// Input: array of hex strings
    /// Output: array of mapped hex strings
    #[wasm_bindgen(js_name = mapColorsHexBatch)]
    pub fn map_colors_hex_batch(&self, hex_colors: Vec<String>) -> Vec<String> {
        hex_colors
            .iter()
            .map(|h| self.map_color_hex(h))
            .collect()
    }
}

impl Default for ColorMapper {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_color_from_hex() {
        let color = Color::from_hex("#ff0000").unwrap();
        assert_eq!(color.r, 255);
        assert_eq!(color.g, 0);
        assert_eq!(color.b, 0);
    }

    #[test]
    fn test_color_to_hex() {
        let color = Color::new(255, 128, 0);
        assert_eq!(color.to_hex(), "#ff8000");
    }

    #[test]
    fn test_color_distance() {
        let c1 = Color::new(0, 0, 0);
        let c2 = Color::new(255, 255, 255);
        let dist = color_distance(&c1, &c2);
        assert!((dist - 441.67).abs() < 0.1);
    }

    #[test]
    fn test_find_closest() {
        let palette = vec![
            Color::new(0, 0, 0),
            Color::new(255, 255, 255),
            Color::new(255, 0, 0),
        ];
        let color = Color::new(200, 10, 10);
        let closest = find_closest(&color, &palette);
        assert_eq!(closest.r, 255);
        assert_eq!(closest.g, 0);
        assert_eq!(closest.b, 0);
    }
}
