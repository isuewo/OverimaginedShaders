vec3 GetAuroraBorealis(vec3 viewPos, float VdotU, float dither) {
    float visibility = sqrt1(clamp01(VdotU * (AURORA_DRAW_DISTANCE * 1.125 + 0.75) - 0.225)) - sunVisibility - rainFactor;
    visibility *= 1.0 - VdotU * 0.75;

    #if AURORA_CONDITION == 1 || AURORA_CONDITION == 3
        visibility -= moonPhase;
    #endif
    #if AURORA_CONDITION == 2 || AURORA_CONDITION == 3
        visibility *= isSnowy;
    #endif

    if (visibility > 0.0) {
        vec3 aurora = vec3(0.0);

        vec3 wpos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
             wpos.xz /= wpos.y;
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
             cameraPositionM.x += syncedTime * 0.04;

        int sampleCount = 25;
        int sampleCountP = sampleCount + 5;
        float ditherM = dither + 5.0;
        float auroraAnimate = frameTimeCounter * 0.0015;

        #ifndef BLOCKY_AURORA
            auroraAnimate /= 2;
        #endif

        #if AURORA_COLOR_PRESET == 0
            vec3 auroraUp = vec3(AURORA_UP_R, AURORA_UP_G, AURORA_UP_B);
            vec3 auroraDown = vec3(AURORA_DOWN_R, AURORA_DOWN_G, AURORA_DOWN_B);
        #else
            vec3 auroraUpA[] = vec3[](
                vec3(112.0, 36.0, 192.0),
                vec3(112.0, 80.0, 255.0),
                vec3(255.0, 80.0, 112.0),
                vec3(72.0, 96.0, 192.0),
                vec3(255.0, 56.0, 64.0),
                vec3(232.0, 116.0, 232.0),
                vec3(212.0, 108.0, 216.0),
                vec3(120.0, 212.0, 56.0),
                vec3(64.0, 255.0, 255.0),
                vec3(168.0, 36.0, 88.0),
                vec3(255.0, 68.0, 124.0)
            );
            vec3 auroraDownA[] = vec3[](
                vec3(96.0, 255.0, 192.0),
                vec3(80.0, 255.0, 180.0),
                vec3(80.0, 255.0, 180.0),
                vec3(172.0, 44.0, 88.0),
                vec3(204.0, 172.0, 12.0),
                vec3(244.0, 188.0, 28.0),
                vec3(92.0, 188.0, 180.0),
                vec3(176.0, 88.0, 72.0),
                vec3(128.0, 64.0, 128.0),
                vec3(60.0, 184.0, 152.0),
                vec3(160.0, 96.0, 255.0)
            );
            #if AURORA_COLOR_PRESET > 1
                int p = AURORA_COLOR_PRESET-1;
            #else
                int p = worldDay % 72 / 8;
            #endif
            vec3 auroraUp = auroraUpA[p];
            vec3 auroraDown = auroraDownA[p];
        #endif
        
        #ifdef RAINBOW_AURORA
            auroraUp *= abs(fract(frameTimeCounter * 0.01 + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
            auroraDown *= abs(fract(frameTimeCounter * 0.01 + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
        #endif

        auroraUp *= (AURORA_UP_I * 0.093 + 3.1) / GetLuminance(auroraUp);
        auroraDown *= (AURORA_DOWN_I * 0.245 + 8.15) / GetLuminance(auroraDown);

        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);

            vec2 planePos = wpos.xz * (AURORA_SIZE * 0.6 + 0.4 + current);
            planePos = planePos * 11.0 + cameraPositionM;

            #ifdef BLOCKY_AURORA
                planePos = floor(planePos);
            #endif

            planePos *= 0.0007;

            float noise = texture2D(noisetex, planePos).b;
            noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));

            #ifndef BLOCKY_AURORA
                planePos /= 100.0;
            #endif

            noise *= pow1_5(texture2D(noisetex, planePos * 100.0 + auroraAnimate).b);
            float currentM = 1.0 - current;

            aurora += noise * currentM * mix(auroraUp, auroraDown, pow2(pow2(currentM)));
        }

        return aurora * visibility / sampleCount;
    }

    return vec3(0.0);
}
