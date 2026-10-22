package com.adso.ia.model;

import org.json.JSONObject;

public class MensajeChat {

    private final String pregunta;
    private final RespuestaIA respuesta;
    private final String error;
    private final String tipo;

    public MensajeChat(String pregunta, RespuestaIA respuesta) {
        this.pregunta = pregunta;
        this.respuesta = respuesta;
        this.error = null;
        this.tipo = "exito";
    }

    public MensajeChat(String pregunta, String error) {
        this.pregunta = pregunta;
        this.respuesta = null;
        this.error = error;
        this.tipo = "error";
    }

    public String getPregunta() {
        return pregunta;
    }

    public RespuestaIA getRespuesta() {
        return respuesta;
    }

    public String getError() {
        return error;
    }

    public String getTipo() {
        return tipo;
    }

    public JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json.put("tipo", tipo);
        json.put("pregunta", pregunta);
        json.put("respuesta", respuesta != null ? respuesta.toJSON() : JSONObject.NULL);
        json.put("error", error != null ? error : JSONObject.NULL);
        return json;
    }
}
