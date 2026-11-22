Shader "Tecsup/Sem10GPC/13_DosFuentesLuz"
{
    Properties
    {
        _BaseColor ("Color Base del Objeto", Color) = (0.9, 0.5, 0.2, 1)
        _AmbientColor ("Color Ambiental", Color) = (0.1, 0.1, 0.1, 1)
        
        _Light1Pos ("Posición Luz 1 (World)", Vector) = (-2, 2, 0, 1)
        _Light1Color ("Color Luz 1", Color) = (1, 0, 0, 1) // Rojo por defecto
        
        _Light2Pos ("Posición Luz 2 (World)", Vector) = (2, 2, 0, 1)
        _Light2Color ("Color Luz 2", Color) = (0, 0, 1, 1) // Azul por defecto

        _SpecularColor ("Color Especular", Color) = (1, 1, 1, 1)
        _Gloss ("Brillo (Shininess)", Range(1, 100)) = 32
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
                float4 _Light1Pos;
                half4 _Light1Color;
                float4 _Light2Pos;
                half4 _Light2Color;
                half4 _SpecularColor;
                half _Gloss;
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
                float3 V = GetWorldSpaceNormalizeViewDir(IN.positionWS);

                // Luz Ambiental base
                half3 ambiental = _BaseColor.rgb * _AmbientColor.rgb;

                // FUENTE 1
                float3 lightDir1 = _Light1Pos.xyz - IN.positionWS;
                float dist1 = length(lightDir1);
                float3 L1 = lightDir1 / dist1;
                float attenuation1 = 1.0 / (1.0 + 0.2 * dist1 * dist1);

                half NdotL1 = saturate(dot(N, L1));
                half3 diffuse1 = _BaseColor.rgb * _Light1Color.rgb * NdotL1 * attenuation1;

                float3 H1 = normalize(L1 + V);
                half spec1 = pow(saturate(dot(N, H1)), _Gloss);
                half3 specular1 = _SpecularColor.rgb * _Light1Color.rgb * spec1 * attenuation1;

                // FUENTE 2
                float3 lightDir2 = _Light2Pos.xyz - IN.positionWS;
                float dist2 = length(lightDir2);
                float3 L2 = lightDir2 / dist2;
                float attenuation2 = 1.0 / (1.0 + 0.2 * dist2 * dist2);

                half NdotL2 = saturate(dot(N, L2));
                half3 diffuse2 = _BaseColor.rgb * _Light2Color.rgb * NdotL2 * attenuation2;

                float3 H2 = normalize(L2 + V);
                half spec2 = pow(saturate(dot(N, H2)), _Gloss);
                half3 specular2 = _SpecularColor.rgb * _Light2Color.rgb * spec2 * attenuation2;

                // Suma de luces
                half3 colorFinal = ambiental + diffuse1 + specular1 + diffuse2 + specular2;

                return half4(colorFinal, 1);
            }
            ENDHLSL
        }
    }
}