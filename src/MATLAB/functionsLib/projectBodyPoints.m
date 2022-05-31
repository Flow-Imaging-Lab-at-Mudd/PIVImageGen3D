function projectedPts = projectBodyPoints(body, cam)

    for npt = 1:length(body.Points)
        ximg = cam.project(body.Points(npt,:)'); % units of mm throughout
        projectedPts(npt,:)=ximg';
    end

end