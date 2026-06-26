$ErrorActionPreference = "Stop"

Write-Host "Creating develop branch"
git checkout -b develop
git push -u origin develop --force
Start-Sleep -Seconds 5

Write-Host "Creating feature/login branch"
git checkout -b feature/login
git commit --allow-empty -m "feat: add login form"
git push -u origin feature/login --force
Start-Sleep -Seconds 5

git commit --allow-empty -m "fix: login button alignment"
git push origin feature/login --force
Start-Sleep -Seconds 5

Write-Host "Merging feature into develop"
git checkout develop
git merge feature/login --no-ff -m "Merge branch 'feature/login' into develop"
git push origin develop --force
Start-Sleep -Seconds 5

Write-Host "Creating permanent release branch from develop"
git checkout -b release
git push -u origin release --force
Start-Sleep -Seconds 5

git commit --allow-empty -m "fix: typo in release"
git push origin release --force
Start-Sleep -Seconds 5

Write-Host "Merging release into main and tagging"
git checkout main
git merge release --no-ff -m "Merge branch 'release' into main"
git tag "1.1.0" -f
git push origin main --force
git push origin --tags --force
Start-Sleep -Seconds 5

Write-Host "Merging main back to release and develop to keep them in sync"
git checkout release
git merge main --no-ff -m "Merge branch 'main' into release"
git push origin release --force
Start-Sleep -Seconds 5

git checkout develop
git merge main --no-ff -m "Merge branch 'main' into develop"
git push origin develop --force
Start-Sleep -Seconds 5

Write-Host "Creating hotfix/1.1.1 from main"
git checkout main
git checkout -b hotfix/1.1.1
git push -u origin hotfix/1.1.1 --force
Start-Sleep -Seconds 5

git commit --allow-empty -m "fix: critical security issue"
git push origin hotfix/1.1.1 --force
Start-Sleep -Seconds 5

Write-Host "Merging hotfix into main and tagging"
git checkout main
git merge hotfix/1.1.1 --no-ff -m "Merge branch 'hotfix/1.1.1' into main"
git tag "1.1.1" -f
git push origin main --force
git push origin --tags --force
Start-Sleep -Seconds 5

Write-Host "Merging hotfix back into release and develop"
git checkout release
git merge main --no-ff -m "Merge branch 'main' into release"
git push origin release --force
Start-Sleep -Seconds 5

git checkout develop
git merge main --no-ff -m "Merge branch 'main' into develop"
git push origin develop --force

Write-Host "DONE PUSHING FLOW TO GITHUB!"
