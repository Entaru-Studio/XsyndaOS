local m = {}

local function buildPath(path, directory)
    if directory and directory ~= "" then
        return fs.combine(directory, path)
    end
    return path
end

function m.write(path, data, mode, directory)
    if not path then
        error("поле path не имеет значения", 2)
    elseif not data then
        error("поле data не имеет значения", 2)
    else
        local fullPath = buildPath(path, directory)
        local handle = fs.open(fullPath, "wb") -- в CC бинарный и текстовый режим одинаковы
        if handle then
            handle.write(data)
            handle.close()
            return true
        else
            return false
        end
    end
end

function m.read(path, mode, directory)
    if not path then
        error("поле path не имеет значения", 2)
    else
        local fullPath = buildPath(path, directory)
        local handle = fs.open(fullPath, "rb")
        if handle then
            local data = handle.readAll()
            handle.close()
            return true, data
        else
            return false
        end
    end
end

function m.rename(path, newPath, directory)
    if not path then
        error("поле path не имеет значения", 2)
    elseif not newPath then
        error("поле newPath не имеет значения", 2)
    else
        local oldFull = buildPath(path, directory)
        local newFull = buildPath(newPath, directory)
        local ok, reason = fs.move(oldFull, newFull)
        if ok then
            return true
        else
            return false, reason
        end
    end
end

function m.remove(path, directory)
    if not path then
        error("поле path не имеет значения", 2)
    end

    local fullPath = buildPath(path, directory)

    if not fs.exists(fullPath) then
        return false, "файл не найден"
    end

    if fs.isDir(fullPath) then
        -- рекурсивное удаление содержимого
        local function delInside(dir)
            for _, name in ipairs(fs.list(dir)) do
                local child = fs.combine(dir, name)
                if fs.isDir(child) then
                    delInside(child)
                    fs.delete(child)
                else
                    fs.delete(child)
                end
            end
        end
        delInside(fullPath)
        local ok, reason = fs.delete(fullPath)
        if ok then
            return true
        else
            return false, reason
        end
    else
        local ok, reason = fs.delete(fullPath)
        if ok then
            return true
        else
            return false, reason
        end
    end
end

function m.folder(path, folderName, directory)
    if not path then
        error("поле path не имеет значения", 2)
    elseif not folderName then
        error("поле folderName не имеет значения", 2)
    else
        local base = buildPath(path, directory)
        local fullPath = fs.combine(base, folderName)
        local ok, reason = fs.makeDir(fullPath)
        if ok then
            return true
        else
            return false, reason
        end
    end
end

function m.list(path, directory)
    local template = { dir = {}, files = {}, unk = {} }
    local base = buildPath(path, directory)

    if not fs.exists(base) or not fs.isDir(base) then
        return template
    end

    for _, name in ipairs(fs.list(base)) do
        local fullPath = fs.combine(base, name)
        if fs.isDir(fullPath) then
            template.dir[#template.dir + 1] = name
        else
            -- CC не различает "файл" и "неизвестное" так, как lfs,
            -- поэтому всё не-папки считаем файлами.
            template.files[#template.files + 1] = name
        end
    end

    return template
end

-- ENTARU STUDIO 2026
-- VERSION 1.2 (CC: Tweaked port)

return m