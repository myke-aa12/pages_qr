from flask import Blueprint, render_template, request, jsonify
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
import logging

from app.database import get_connection

ant_federal = Blueprint(
    "ant_federal",
    __name__,
    template_folder="."
)

@ant_federal.route("/public/seguridad/fiscalia/noantecedentes")
def inicio():
    return render_template("index.html")

@ant_federal.route("/api/validacionfederal/<sello>")
def obtener_validacionfederal(sello):
    """
    Obtiene los datos de validación usando el sello como llave
    
    Args:
        sello: Sello único de la constancia
    
    Returns:
        JSON con datos de la validación o error 404
    """
    
    if not sello or sello.strip() == "":
        return jsonify({'error': 'Sello no válido'}), 400

    db = get_connection()

    try:
        consulta = text("""
            SELECT nombre_completo, curp, fecha_expedicion, vigencia, folio
            FROM qr_antec_fed
            WHERE SELLO = :sello
            LIMIT 1
        """)

        row = db.execute(
            consulta,
            {"sello": sello}
        ).mappings().first()

        if row is None:
            return jsonify({'error': 'Constancia no encontrada'}), 404

        return jsonify({
            'success': True,
            'sello': sello,
            'nombre_completo': row['NOMBRE_COMPLETO'],
            'curp': row['CURP'],
            'fecha_expedicion': row['FECHA_EXPEDICION'],
            'vigencia': row['VIGENCIA'],
            'folio': row['FOLIO']
        }), 200

    except SQLAlchemyError as e:
        logging.exception("Error consultando qr_antec_fed en MySQL")
        return jsonify({'error': 'Error al consultar la base de datos'}), 500

    finally:
        db.close()