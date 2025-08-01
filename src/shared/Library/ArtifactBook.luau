local ReplicatedStorage = game:GetService("ReplicatedStorage")



local ArtifactRawBook = require(ReplicatedStorage.HarukaShared.Library.ArtifactRawBook)

local ArtifactBook = {}



function ArtifactBook:GetArtifactInfo(artifactId: string) : {
    ArtifactId: string,
    ArtifactTitle: string,
    TwoPieceEff: string,
    FourPieceEff: string,
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



return ArtifactBook
