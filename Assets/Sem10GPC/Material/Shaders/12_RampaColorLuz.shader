Shader "Tecsup/Sem10GPC/12_RampaColorLuz"
{
    Properties
    {
        _BaseColor ("Color Base", Color) = (1, 1, 1, 1)
        _ShadowColor ("Color de Sombra", Color) = (0.1, 0.1, 0.3, 1)
        _LightColor ("Color de Luz", Color) = (0.9, 0.8, 0.6, 1)
        _SkyColor ("Color de Cielo (Hemisférica)", Color) = (0.4, 0.6, 0.9, 1)
        _GroundColor ("Color de Suelo (Hemisférica)", Color) = (0.3, 0.2, 0.1, 1)
        _AmbientIntensity ("Intensidad Hemisférica", Range(0, 2)) = 1.0
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

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _ShadowColor;
                half4 _LightColor;
                half4 _SkyColor;
                half4 _GroundColor;
                half _AmbientIntensity;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 N = normalize(IN.normalWS);
                Light luz = GetMainLight();
                float3 L = normalize(luz.direction);

                half NdotL = saturate(dot(N, L));
                half3 colorRampa = lerp(_ShadowColor.rgb, _LightColor.rgb * luz.color, NdotL);

                half hemisFactor = N.y * 0.5 + 0.5;
                half3 luzHemisferica = lerp(_GroundColor.rgb, _SkyColor.rgb, hemisFactor) * _AmbientIntensity;

                half3 colorFinal = _BaseColor.rgb * (colorRampa + luzHemisferica);

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}