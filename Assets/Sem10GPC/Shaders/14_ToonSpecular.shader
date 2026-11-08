Shader "Tecsup/Sem10GPC/14_ToonSpecular"
{
    Properties
    {
        _BaseColor ("Color Base", Color) = (0.9, 0.5, 0.2, 1)
        _AmbientColor ("Color Ambiental", Color) = (0.3, 0.3, 0.3, 1)
        
        _Threshold ("Umbral de Sombra", Range(0, 1)) = 0.5
        _Smoothness ("Suavizado de Sombra", Range(0.001, 0.1)) = 0.05
        
        _SpecularColor ("Color Especular (Highlight)", Color) = (1, 1, 1, 1)
        _SpecThreshold ("Umbral Especular", Range(0, 1)) = 0.8
        _SpecSmoothness ("Suavizado Especular", Range(0.001, 0.1)) = 0.02
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
                half4 _AmbientColor;
                float _Threshold;
                float _Smoothness;
                half4 _SpecularColor;
                float _SpecThreshold;
                float _SpecSmoothness;
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
                float3 positionWS : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 N = normalize(IN.normalWS);
                Light luz = GetMainLight();
                float3 L = normalize(luz.direction);
                float3 V = GetWorldSpaceNormalizeViewDir(IN.positionWS);

                half NdotL = dot(N, L);
                half toonIntensity = smoothstep(_Threshold - _Smoothness, _Threshold + _Smoothness, NdotL);

                float3 H = normalize(L + V);
                half NdotH = saturate(dot(N, H));
                half toonSpecular = smoothstep(_SpecThreshold - _SpecSmoothness, _SpecThreshold + _SpecSmoothness, NdotH);

                half3 ambiental = _BaseColor.rgb * _AmbientColor.rgb;
                half3 difuso = _BaseColor.rgb * luz.color * toonIntensity;
                half3 especular = _SpecularColor.rgb * luz.color * toonSpecular;

                half3 colorFinal = ambiental + difuso + especular;

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}