function projectedPts = projectBodyPoints(body, cam)

    for npt = 1:length(body.Points)
        ximg = cam.project(body.Points(npt,:)'/1000); % unit conversion mm to m included
        projectedPts(npt,:)=ximg';
    end

end