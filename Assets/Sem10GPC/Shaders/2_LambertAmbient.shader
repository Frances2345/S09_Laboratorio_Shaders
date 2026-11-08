Shader "Tecsup/Sem10GPC/2_LambertAmbient"
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

                half NdotL = saturate(dot(N, luz.direction));
                half3 difuso = _BaseColor.rgb * luz.color * NdotL;

                half3 ambiental = _BaseColor.rgb * _AmbientColor.rgb;

                half3 colorFinal = ambiental + difuso;

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}