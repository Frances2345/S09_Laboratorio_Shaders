Shader "Tecsup/Sem10GPC/9_ToonMultitextura"
{
    Properties
    {
        _BaseMap1 ("Textura 1 (Negro)", 2D) = "white" {}
        _BaseMap2 ("Textura 2 (Blanco)", 2D) = "white" {}
        _MaskMap ("Máscara (Escala de Grises)", 2D) = "white" {}
        _AmbientColor ("Color Ambiental", Color) = (0.3, 0.3, 0.3, 1)
        _Threshold ("Umbral de Sombra (Bandas)", Range(0, 1)) = 0.5
        _Smoothness ("Suavizado de Banda", Range(0.001, 0.1)) = 0.05
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_BaseMap1);
            SAMPLER(sampler_BaseMap1);
            TEXTURE2D(_BaseMap2);
            SAMPLER(sampler_BaseMap2);
            TEXTURE2D(_MaskMap);
            SAMPLER(sampler_MaskMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap1_ST;
                float4 _BaseMap2_ST;
                float4 _MaskMap_ST;
                half4 _AmbientColor;
                float _Threshold;
                float _Smoothness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap1);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 N = normalize(IN.normalWS);
                Light luz = GetMainLight();
                float3 L = normalize(luz.direction);

                half4 col1 = SAMPLE_TEXTURE2D(_BaseMap1, sampler_BaseMap1, IN.uv);
                half4 col2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, IN.uv);
                half mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, IN.uv).r;

                half3 mixedTexture = lerp(col1.rgb, col2.rgb, mask);

                half NdotL = dot(N, L);
                half toonIntensity = smoothstep(_Threshold - _Smoothness, _Threshold + _Smoothness, NdotL);

                half3 ambiental = mixedTexture * _AmbientColor.rgb;
                half3 difuso = mixedTexture * luz.color * toonIntensity;

                half3 colorFinal = ambiental + difuso;

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}