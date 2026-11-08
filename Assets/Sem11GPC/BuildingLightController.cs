using UnityEngine;

public class BuildingLightController : MonoBehaviour
{
    [Header("Referencia del Ciclo")]
    public DayNightCycle dayNightCycle;
    private Material buildingMaterial;

    [Header("Configuración de Emisión")]
    public Color nightEmissionColor = new Color(1f, 0.8f, 0.4f) * 2f;
    private Color dayEmissionColor = Color.black;

    void Start()
    {
        Renderer buildingRenderer = GetComponent<Renderer>();
        if (buildingRenderer != null)
        {
            buildingMaterial = buildingRenderer.material;
        }
        else
        {
            Debug.LogWarning("No se encontró el componente Renderer en este objeto de edificación.");
        }
    }

    void Update()
    {
        if (dayNightCycle == null || buildingMaterial == null) return;

        if (dayNightCycle.IsDay())
        {
            buildingMaterial.DisableKeyword("_EMISSION");
            buildingMaterial.SetColor("_EmissionColor", dayEmissionColor);
        }
        else
        {
            buildingMaterial.EnableKeyword("_EMISSION");
            buildingMaterial.SetColor("_EmissionColor", nightEmissionColor);
        }
    }
}