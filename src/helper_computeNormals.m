function [vertexNormals,faceNormals]=helper_computeNormals(X,faces)


vertexNormals=zeros(size(X));
faceNormals=zeros(3,size(faces,1));
nfaces=size(faces,2);

for i=1:size(faces,1)
    for j=1:size(faces,2)
        idx=faces(i,j);
        if j==1, idxprev=faces(i,nfaces); else idxprev=faces(i,j-1); end
        if j==nfaces, idxnext=faces(i,1); else idxnext=faces(i,j+1); end
        v=X(:,idx);
        vprev=X(:,idxprev);
        vnext=X(:,idxnext);
        n=cross(vnext-v,vprev-v);
        n=n/norm(n);
        vertexNormals(:,idx)=vertexNormals(:,idx)+n;
        if j==2
            faceNormals(:,i)=n;
        end
    end
end

for i=1:size(vertexNormals,2)
    vertexNormals(:,i)=vertexNormals(:,i)/norm(vertexNormals(:,i));
end


for i=1:size(faceNormals,2)
    faceNormals(:,i)=faceNormals(:,i)/norm(faceNormals(:,i));
end

end