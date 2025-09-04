#!/bin/bash
set -e

# -------------------------------------------
# QuickPod / Ubuntu SSHServer ComfyUI Provisioning Script
# -------------------------------------------

# --- Environment Variables ---
# export CIVITAI_TOKEN="your_civitai_token_here"
# export HF_TOKEN="your_huggingface_token_here"

# --- Universal venv handling ---
if [ -d "/venv" ]; then
    echo "[INFO] Activating QuickPod venv..."
    source /venv/bin/activate
else
    echo "[INFO] Creating new venv in /workspace/venv..."
    python3 -m venv /workspace/venv
    source /workspace/venv/bin/activate
fi

python -m pip install --upgrade pip

# --- Install ComfyUI ---
COMFYUI_DIR="/workspace/ComfyUI"
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "[INFO] Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_DIR"
fi
cd "$COMFYUI_DIR"
pip install --no-cache-dir -r requirements.txt
python -m pip install --upgrade comfyui-frontend-package

# --- Optional APT packages ---
APT_PACKAGES=()
if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
    sudo apt update
    sudo apt install -y "${APT_PACKAGES[@]}"
fi

# --- Optional PIP packages ---
PIP_PACKAGES=()
if [[ ${#PIP_PACKAGES[@]} -gt 0 ]]; then
    pip install --no-cache-dir "${PIP_PACKAGES[@]}"
fi

# --- Custom Nodes ---
NODES=(
"https://github.com/ltdrdata/ComfyUI-Manager"
"https://github.com/cubiq/ComfyUI_essentials"
"https://github.com/rgthree/rgthree-comfy"
"https://github.com/ltdrdata/ComfyUI-Impact-Pack"
"https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
"https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
"https://github.com/ai-shizuka/ComfyUI-tbox"
"https://github.com/alt-key-project/comfyui-dream-project"
"https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes"
"https://github.com/FizzleDorf/ComfyUI_FizzNodes"
"https://github.com/Gourieff/ComfyUI-ReActor"
"https://github.com/TinyTerra/ComfyUI_tinyterraNodes"
"https://github.com/chrisgoringe/cg-use-everywhere"
"https://github.com/storyicon/comfyui_segment_anything"
"https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
"https://github.com/kijai/ComfyUI-KJNodes"
"https://github.com/WASasquatch/was-node-suite-comfyui"
"https://github.com/Fannovel16/comfyui_controlnet_aux"
"https://github.com/cardenluo/ComfyUI-Apt_Preset"
"https://github.com/jakechai/ComfyUI-JakeUpgrade"
"https://github.com/jamesWalker55/comfyui-various"
"https://github.com/mav-rik/facerestore_cf"
"https://github.com/BadCafeCode/masquerade-nodes-comfyui"
"https://github.com/Fannovel16/ComfyUI-Frame-Interpolation"
"https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet"
"https://github.com/jags111/efficiency-nodes-comfyui"
"https://github.com/chflame163/ComfyUI_LayerStyle"
"https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved"
"https://github.com/cubiq/ComfyUI_IPAdapter_plus"
"https://github.com/kijai/ComfyUI-segment-anything-2"
"https://github.com/kijai/ComfyUI-Florence2"
"https://github.com/city96/ComfyUI-GGUF"
)

download_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="${COMFYUI_DIR}/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            echo "[INFO] Updating node: $dir..."
            ( cd "$path" && git pull )
        else
            echo "[INFO] Cloning node: $dir..."
            git clone "$repo" "$path" --recursive
        fi
        if [[ -f "$requirements" ]]; then
            echo "[INFO] Installing node requirements for $dir..."
            pip install --upgrade --force-reinstall --no-cache-dir -r "$requirements"
        fi
    done
}

# --- Model download helper ---
download_models() {
    base_dir="$1"
    shift
    urls=("$@")
    mkdir -p "$base_dir"

    for url in "${urls[@]}"; do
        subdir=""
        [[ "$url" == *"flux"* ]] && subdir="flux"
        [[ "$url" == *"stable-diffusion"* || "$url" == *"sd"* ]] && subdir="sd"
        [[ "$url" == *"schnell"* ]] && subdir="schnell"
        [[ "$url" == *"dev"* ]] && subdir="dev"

        outdir="$base_dir"
        [[ -n "$subdir" ]] && outdir="${base_dir}/${subdir}"
        mkdir -p "$outdir"

        echo "[INFO] Downloading: $url -> $outdir"
        if [[ "$url" == *"huggingface.co"* && -n "$HF_TOKEN" ]]; then
            wget --header="Authorization: Bearer $HF_TOKEN" --content-disposition "$url" -P "$outdir"
        else
            wget --content-disposition "$url" -P "$outdir"
        fi
    done
}

echo "[INFO] Provisioning setup complete. Part 2 will define all model URLs and start downloads."

# -------------------------------------------
# Part 2: Model URLs and Downloads
# -------------------------------------------

# --- Checkpoints ---
CHECKPOINT_MODELS=(
"https://civitai.com/api/download/models/1512379?token=$CIVITAI_TOKEN"
"https://civitai.com/api/download/models/1916865?token=$CIVITAI_TOKEN"
"https://civitai.com/api/download/models/1634588?token=$CIVITAI_TOKEN"
"https://civitai.com/api/download/models/176425?token=$CIVITAI_TOKEN"
)

# --- Loras Characters ---
LORA_CHARACTERS=(
    "https://civitai.com/api/download/models/1565120?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/61541?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1559149?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1559132?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1559178?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1559358?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1559222?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1453689?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/221626?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1245593?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/83770?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1389554?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1389565?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1352203?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1352197?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1352192?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1352176?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1352138?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1339370?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1339366?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1339368?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1330640?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1330636?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1330633?token=$CIVITAI_TOKEN"
    
    "https://civitai.com/api/download/models/1607079?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1380884?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1380921?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1381003?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1405207?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1448250?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1713037?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1713050?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1713071?token=$CIVITAI_TOKEN"

    
    
    "https://civitai.com/api/download/models/1330634?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/2095986?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/2094312?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1866302?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/2119240?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1900036?token=$CIVITAI_TOKEN"
)

# --- Loras Styles ---
LORA_STYLES=(
    "https://civitai.com/api/download/models/998850?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1385235?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1388229?token=$CIVITAI_TOKEN"    
    "https://civitai.com/api/download/models/1401771?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/136749?token=$CIVITAI_TOKEN"
)

# --- Loras Clothing ---
LORA_CLOTHING=(
    "https://civitai.com/api/download/models/1257965?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1307299?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1533931?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1525419?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1533873?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1586336?token=$CIVITAI_TOKEN"
    
    "https://civitai.com/api/download/models/1789416?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1826319?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1830709?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1904614?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1904658?token=$CIVITAI_TOKEN"
)

# --- Loras Concept ---
LORA_CONCEPT=(
    "https://civitai.com/api/download/models/1571734?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1547356?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1168401?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/140535?token=$CIVITAI_TOKEN"
)

# --- ADetailer ---
ADETAILER_MODELS=(
    "https://civitai.com/api/download/models/465360?token=$CIVITAI_TOKEN"
)

# --- SAM ---
SAM_MODELS=(
    "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"
)

# --- Diffusion Models ---
DIFFUSION_MODELS=(
    "https://huggingface.co/YarvixPA/FLUX.1-Fill-dev-GGUF/resolve/154e0cd504b5765212c9c1c677a800d5a923c356/flux1-fill-dev-Q8_0.gguf"
)

# --- CLIP Vision ---
CLIP_VISION_MODELS=()

# --- Text Encoders ---
TEXT_ENCODER_MODELS=(
    #flux
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"
    #sd
    "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors"
    "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/t5xxl_fp8_e4m3fn.safetensors"
)

# --- VAEs ---
VAE_MODELS=(
    #flux
    "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors"
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
)

# --- ControlNet ---
CONTROLNET_MODELS=(
# Add URLs here if needed
)

# --- Start Downloading Models ---
echo "[INFO] Downloading custom nodes..."
download_nodes

echo "[INFO] Downloading Checkpoints..."
download_models "${COMFYUI_DIR}/models/checkpoints" "${CHECKPOINT_MODELS[@]}"

echo "[INFO] Downloading Loras Characters..."
download_models "${COMFYUI_DIR}/models/loras/characters" "${LORA_CHARACTERS[@]}"

echo "[INFO] Downloading Loras Styles..."
download_models "${COMFYUI_DIR}/models/loras/styles" "${LORA_STYLES[@]}"

echo "[INFO] Downloading Loras Clothing..."
download_models "${COMFYUI_DIR}/models/loras/clothing" "${LORA_CLOTHING[@]}"

echo "[INFO] Downloading Loras Concept..."
download_models "${COMFYUI_DIR}/models/loras/concept" "${LORA_CONCEPT[@]}"

echo "[INFO] Downloading ADetailer Models..."
download_models "${COMFYUI_DIR}/models/ultralytics/segm" "${ADETAILER_MODELS[@]}"

echo "[INFO] Downloading SAM Models..."
download_models "${COMFYUI_DIR}/models/sams" "${SAM_MODELS[@]}"

echo "[INFO] Downloading Diffusion Models..."
download_models "${COMFYUI_DIR}/models/diffusion_models" "${DIFFUSION_MODELS[@]}"

echo "[INFO] Downloading CLIP Vision Models..."
download_models "${COMFYUI_DIR}/models/clip_vision" "${CLIP_VISION_MODELS[@]}"

echo "[INFO] Downloading Text Encoder Models..."
download_models "${COMFYUI_DIR}/models/text_encoders" "${TEXT_ENCODER_MODELS[@]}"

echo "[INFO] Downloading VAE Models..."
download_models "${COMFYUI_DIR}/models/vae" "${VAE_MODELS[@]}"

echo "[INFO] Downloading ControlNet Models..."
download_models "${COMFYUI_DIR}/models/controlnet" "${CONTROLNET_MODELS[@]}"

echo "[INFO] All provisioning and model downloads complete!"
