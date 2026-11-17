from flask import Blueprint, render_template, request, jsonify
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
import logging

from app.database import get_connection

ant_estatal = Blueprint(
    "ant_estatal",
    __name__,
    template_folder="."
)

@ant_estatal.route("/public/seguridad/fiscalia/noantecedentes")
@ant_estatal.route("/public/seguridad/fiscalia/noantecedentes-estatal")
def inicio():
    return render_template("ant_estatal/index.html")

@ant_estatal.route("/api/validacionestatal/<sello>")
def obtener_validacionestatal(sello):
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
            SELECT NOMBRE_COMPLETO, CURP, FECHA_EXPEDICION, VIGENCIA, FOLIO
            FROM qr_antec_est
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
        logging.exception("Error consultando qr_antec_est en MySQL")
        return jsonify({'error': 'Error al consultar la base de datos'}), 500

    finally:
        db.close()