-- modules/toggle_lsp.lua

local M = {}

local lspconfig = require('lspconfig')

-- Function to stop yamlls client
function M.stop_yamlls()
    for _, client in pairs(vim.lsp.get_active_clients()) do
        if client.name == 'yamlls' then
            client.stop()
        end
    end
end

-- Function to start yamlls client
function M.start_yamlls()
    lspconfig.yamlls.setup {
        on_attach = function(client)
            -- Add any custom on_attach behavior here if needed
        end,
        settings = {
            yaml = {
                schemaStore = {
                    enable = true,
                    url = "https://www.schemastore.org/api/json/catalog.json",
                },
                schemas = {
                    -- ArgoCD ApplicationSet CRD
                    ["https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml"] = "",
                    -- ArgoCD Application CRD
                    ["https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/application-crd.yaml"] = "",
                    -- Kubernetes strict schemas
                    ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.3-standalone-strict/all.json"] = "",
                },
                validate = true,
                completion = true,
                hover = true,
                format = {
                    enable = true,
                    bracketSpacing = true,
                    printWidth = 80,
                    proseWrap = "preserve",
                    singleQuote = true,
                },
                customTags = {
                    "!Ref",
                    "!Sub sequence",
                    "!Sub mapping",
                    "!GetAtt",
                },
                disableAdditionalProperties = false,
                maxItemsComputed = 5000,
                trace = {
                    server = "verbose",
                },
            },
            redhat = {
                telemetry = {
                    enabled = false,
                },
            },
        },
    }
    -- Manually attach yamlls to the current buffer
    vim.lsp.buf_attach_client(vim.api.nvim_get_current_buf(), vim.lsp.start_client({
        name = 'yamlls',
        cmd = lspconfig.yamlls.cmd,
        root_dir = lspconfig.util.root_pattern("."),
    }))
end

-- Function to toggle between yaml and helm filetypes
function M.toggle_yaml_helm()
    if vim.bo.filetype == 'yaml' then
        vim.bo.filetype = 'helm'
        M.stop_yamlls()
    elseif vim.bo.filetype == 'helm' then
        vim.bo.filetype = 'yaml'
        M.start_yamlls()
    end
end

return M
