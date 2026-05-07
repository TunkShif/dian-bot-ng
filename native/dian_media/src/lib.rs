use rustler::{Binary, Env, OwnedBinary};
use std::io::Write;
use std::sync::Arc;

#[rustler::nif(schedule = "DirtyCpu")]
fn render<'a>(
    env: Env<'a>,
    svg: String,
    font_paths: Vec<String>,
    scale: f64,
    max_pixels: u32,
    load_system_fonts: bool,
) -> Result<(Binary<'a>, u32, u32), String> {
    let mut fontdb = fontdb::Database::new();
    if load_system_fonts {
        fontdb.load_system_fonts();
    }

    for path in font_paths {
        let path = std::path::Path::new(&path);
        if path.is_file() {
            fontdb
                .load_font_file(path)
                .map_err(|err| format!("failed to load font {}: {}", path.display(), err))?;
        }
    }

    let options = usvg::Options {
        font_family: "sans-serif".into(),
        fontdb: Arc::new(fontdb),
        ..Default::default()
    };

    let tree = usvg::Tree::from_str(&svg, &options).map_err(|_| "invalid_svg".to_string())?;

    let base_size = tree.size().to_int_size();
    let width = scaled_dimension(base_size.width(), scale)?;
    let height = scaled_dimension(base_size.height(), scale)?;

    if width.saturating_mul(height) > max_pixels {
        return Err("image_too_large".to_string());
    }

    let mut pixmap = tiny_skia::Pixmap::new(width, height)
        .ok_or_else(|| "failed to create pixmap".to_string())?;

    let transform = tiny_skia::Transform::from_scale(scale as f32, scale as f32);
    resvg::render(&tree, transform, &mut pixmap.as_mut());

    let png = pixmap
        .encode_png()
        .map_err(|err| format!("failed to encode png: {}", err))?;

    let mut binary = OwnedBinary::new(png.len())
        .ok_or_else(|| "failed to allocate png binary".to_string())?;

    binary
        .as_mut_slice()
        .write_all(&png)
        .map_err(|err| err.to_string())?;

    Ok((binary.release(env), width, height))
}

fn scaled_dimension(value: u32, scale: f64) -> Result<u32, String> {
    let scaled = ((value as f64) * scale).round();

    if !scaled.is_finite() || scaled <= 0.0 || scaled > (u32::MAX as f64) {
        return Err("image_too_large".to_string());
    }

    Ok(scaled as u32)
}

rustler::init!("Elixir.Dian.Media.SvgRenderer");
