Shader "Tecsup/Sem10GPC/11_PhongVsBlinnPhong"
{
    Properties
    {
        _BaseColor ("Color del objeto", Color) = (0.9, 0.5, 0.2, 1)
        _AmbientColor ("Color ambiental", Color) = (0.2, 0.2, 0.2, 1)
        _SpecularColor ("Color especular", Color) = (1, 1, 1, 1)
        _Gloss ("Brillo (Shininess)", Range(1, 100)) = 32
        [Toggle] _UseBlinnPhong ("Usar Blinn-Phong (Desmarcar para Phong)", Float) = 1
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
                half4 _SpecularColor;
                half _Gloss;
                half _UseBlinnPhong;
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

                half NdotL = saturate(dot(N, L));
                half3 ambiental = _BaseColor.rgb * _AmbientColor.rgb;
                half3 difuso = _BaseColor.rgb * luz.color * NdotL;

                half especularIntensidad = 0;

                if (_UseBlinnPhong > 0.5)
                {
                    float3 H = normalize(L + V);
                    half NdotH = saturate(dot(N, H));
                    especularIntensidad = pow(NdotH, _Gloss);
                }
                else
                {
                    float3 R = reflect(-L, N);
                    half RdotV = saturate(dot(R, V));
                    especularIntensidad = pow(RdotV, _Gloss);
                }

                half3 especular = _SpecularColor.rgb * luz.color * especularIntensidad;
                half3 colorFinal = ambiental + difuso + especular;

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}