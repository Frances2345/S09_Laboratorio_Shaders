Shader "Tecsup/Sem10GPC/10_FlatShading"
{
    Properties
    {
        _BaseColor ("Color del objeto", Color) = (0.9, 0.5, 0.2, 1)
        _AmbientColor ("Color ambiental", Color) = (0.2, 0.2, 0.2, 1)
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
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 dx = ddx(IN.positionWS);
                float3 dy = ddy(IN.positionWS);
                float3 N = normalize(cross(dy, dx));

                float3 V = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                if (dot(N, V) < 0) N = -N;

                Light luz = GetMainLight();
                float3 L = normalize(luz.direction);

                half NdotL = saturate(dot(N, L));
                half3 ambiental = _BaseColor.rgb * _AmbientColor.rgb;
                half3 difuso = _BaseColor.rgb * luz.color * NdotL;

                half3 colorFinal = ambiental + difuso;

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}