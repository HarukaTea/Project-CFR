--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")



local ArtifactRawBook = require(ReplicatedStorage.HarukaShared.Library.ArtifactRawBook)

local ArtifactBook = {}



function ArtifactBook:GetArtifactInfo(artifactId: string) : {
    ArtifactId: string,
    ArtifactTitle: string,
    TwoPieceEff: string,
    ThreePieceEff: string,
}
    artifactId = artifactId or "none"
    local info = {}

    for _, artifactInfo in ArtifactRawBook do
        if artifactInfo.ArtifactId == artifactId then
            info = artifactInfo
            break
        end
    end

    return info
end


function ArtifactBook:GetAllArtifactIds() : { string }
    local ids = {}

    for _, artifactInfo in ArtifactRawBook do
        if not table.find(ids, artifactInfo.ArtifactId) then
            table.insert(ids, artifactInfo.ArtifactId)
        end
    end

    return ids
end



return ArtifactBook