operation: https://github.com/doda2025-team8/operation/releases/tag/a1  
app-frontend: https://github.com/doda2025-team8/app-frontend/releases/tag/a1    
app-service:  https://github.com/doda2025-team8/app-service/releases/tag/a1  
model-service: https://github.com/doda2025-team8/model-service/releases/tag/a1  
lib-version: https://github.com/doda2025-team8/lib-version/releases/tag/a1


## Comments for A1:
For A1 all features where implemented, namely **F1**, **F2**, **F3**, **F4**, **F5**, **F6**, **F7**, **F8**, **F9**, **F10**, **F11**. 

You can follow the instruction in the **README** in the ``operation`` repository to run the application. 

Additional details are available in the README files of each repository.

Notes:
- We decided to split the app into to different repositories; ``app-service`` and ``app-fronted``. In ``app-service`` you can find the API gateway and in ``app-fronted`` the UI of the application.
- An NGINX reverse proxy was configured to serve the frontend and safely forward API calls to the backend from the same origin to avoid CORS issues.
- Advanced versioning was implemented to ``lib-version``, ``model-service``, ``app-service``, ``app-frontend``.
- All features concerning the ``app`` were implemented to both ``app-service`` and ``app-frontend``, following our decision to split the application.
