--[[
    Git clone Library based on
    Based on : https://github.com/Konijima/cc-git-clone
--]]

local gclone = {}

gclone.gitTreeUrl = 'https://api.github.com/repos/[USER]/[REPO]/git/trees/[BRANCH]?recursive=1'
gclone.rawFileUrl = 'https://raw.githubusercontent.com/[USER]/[REPO]/[BRANCH]/[PATH]'

gclone.user = nil
gclone.repo = nil
gclone.branch = nil
gclone.localPath = nil

--[[ 
    Clones a all files in the list
--]]
function gclone.cloneFiles(files)
    local processes = {}
    local x, y = term.getCursorPos()

    local localRepoPath = fs.combine(gclone.localPath, gclone.repo)
    if fs.exists(localRepoPath) then
        fs.delete(localRepoPath)
    end

    local downloadedCount = 0
    for i=1, #files do
        local function download()
            local filePath = fs.combine(localRepoPath, files[i].path)

            local request, err = http.get(files[i].url, nil, files[i].binary)
            if not request then
                printerror("reason: " .. tostring(err))
                return nil
            end
            local content = request.readAll()
            request.close()

            local mode = 'w'
            if files[i].binary then
                mode = 'wb'
            end
            
            local writer = fs.open(filePath, mode)
            writer.write(content)
            writer.close()

            term.setCursorPos(x, y)
            term.clearLine()
            downloadedCount = downloadedCount + 1
            local progressText = 'Receiving files:  ' .. (downloadedCount / #files * 100) .. '% (' .. downloadedCount .. '/' .. #files .. ')'
            if downloadedCount ~= #files then
                term.write(progressText)
            else
                print(progressText)
            end
        end
        if not download then
            print("SKIPPING ["..i.."]")
            goto continue
        end
        table.insert(processes, download)
        ::continue::
    end
    parallel.waitForAll(table.unpack(processes))
end

--[[
    Sets the variables of the path to clone
    # ARGS
    @user: repo's user
    @repo: the repo's name
    @branch: the branch to clone
    @[opt]localPath: the local path to store the repo to, 
        or use the current dir
--]]
function gclone.setTarget(user, repo, branch, localPath)
    gclone.user = user
    gclone.repo = repo
    gclone.branch = branch

    gclone.localPath = localPath or shell.dir()

    gclone.gitTreeUrl = gclone.gitTreeUrl:gsub('%[USER]', user)
    gclone.gitTreeUrl = gclone.gitTreeUrl:gsub('%[REPO]', repo)
    gclone.gitTreeUrl = gclone.gitTreeUrl:gsub('%[BRANCH]', branch)
end

--[[
    Clones a git repo into cc
    # ARGS
    @user: repo's user
    @repo: the repo's name
    @branch: the branch to clone
    @[opt]localPath: the local path to store the repo to, 
        or use the current dir
--]]
function gclone.clone(user, repo, branch, localpath)
    gclone.setTarget(user, repo, branch, localpath)

    print(("Cloning: %s/%s:[%s] to `%s`"):format(user, repo, branch, gclone.localPath))

    local res, reason = http.get(gclone.gitTreeUrl)
    if not reason then
        local tree = res.readAll()
        tree = textutils.unserialiseJSON(tree)
        local files = {}
        for k, entry in pairs(tree.tree) do
            if entry.type ~= "tree" then
                local url = gclone.rawFileUrl
                url = url:gsub('%[USER]', user)
                url = url:gsub('%[REPO]', repo)
                url = url:gsub('%[BRANCH]', branch)
                url = url:gsub('%[PATH]', entry.path)
                table.insert(files, { path = entry.path, url = url, binary = entry.type == "blob" })
            end
        end
        print('Cloning into ' .. repo .. '...')
        gclone.cloneFiles(files)
    else
        printError(reason)
    end
end

return gclone