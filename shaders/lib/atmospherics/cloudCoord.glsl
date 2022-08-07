#ifdef DEFERRED1
    const float cloudRoundness = 0.125; // for clouds 0.125
#else
    const float cloudRoundness = 0.35; // for cloud shadows
#endif

vec2 GetRoundedCloudCoord(vec2 pos) { // Thanks to SixthSurge
    vec2 coord = pos.xy + 0.5;
    vec2 signCoord = sign(coord);
    coord = abs(coord) + 1.0;
    vec2 i, f = modf(coord, i);
    f = smoothstep(0.5 - cloudRoundness, 0.5 + cloudRoundness, f);
    coord = i + f;
    return (coord - 0.5) * signCoord / 256.0;
}

vec3 ModifyTracePos(vec3 tracePos, float cloudAltitude) {
    tracePos.x += syncedTime * CLOUD_SPEED;
    tracePos.z += cloudAltitude * 64.0;
    tracePos.xz *= CLOUD_WIDTH;
    return tracePos.xyz;
}