OVERVIEW:
Cardly must be, basically a clone of Anki (https://apps.ankiweb.net/), we can plagiarize it a lot because this is only an academical project, without profitable intentions and will go to production for a short period of time so we can present it and shut it down. The project was started already but we want to start again, so you can delete what you think it's necessary. The front needs rework, it's not great, and we want a good card flip animation like the one here: https://www.w3schools.com/howto/howto_css_flip_card.asp but the one in the link flips on hover and ours must flip when the user clicks the button to see the answer.

DESIGN AND MAIN CORE:
We have a pdf (Flashcards.pdf) in the directory C:/projects/cardly. This pdf is the first one we presented to the teacher, so we want to follow it as much as we can, but we do have flexibility to change a little bit, so you can be creative.
The focus is a flashcard app (like Anki) focused on the learning of different subjects with a dashboard so the user can follow his progress.
We have some reqs demanded directly by the teacher:
- Day gap between one try and another try of the card, based on it's difficulty. Example: if the card level is HARD, the user will be able to do it again in X days, if it's easy the user will be able to do it again in Y days. This rule was already implemented on the project, seek for it and keep as it is.
- Card difficulty level must be setted by the system, seek if we have this rule implemented, if we do keep it, if not, create it based on Anki rules or something that you find on the internet, you are free to define this rule.
- A calendar highlighting the days when the user did any cards, inspire the design on menstrual control apps like Clue.
- An administrator vision, where it would be able to create, update and remove users, cards and subjects.
Our app will go to production as it is one of the requirements made by the professor, so we will use Vercel + something for the back (maybe railway or aws free tier), so you must prepare the app to work on prd too.

DOCUMENTATION:
This section is the most important of the project, the teacher was VERY rigid about the documentation and it have a very big weight on the final grade, so pay atention.
We have this documentation model approved by the teacher: https://www.overleaf.com/project/6a26a6c90e367279398c0cc9
This doc (template_doc.pdf) is also at C:/projects/cardly if you are not able to see it by requesting the url, the only diff between the template doc and ours is the font: use ABNT rules for sizes and times new roman as font.
One agent must create the documentation and 3 others must review it, 2 of those 3 reviewers must be Opus 4.8.
We want a lot of references (all of them following ABNT rules). The teacher said we need to add the reference for everything: a video watched that helped to understand any concept, a stackoverflow post, a medium article, etc. So do it and keep in mind that this project is being done by students currently on the 7th semester of software engineering that don't know a lot about mobile development, so be consistent when choosing the references.

COMMITS:
We want commits to be as real as possible, so you should manipulate the commit dates and authors, the dates and times must be somewhere between 29/05/2026 and 10/06/2026, and the authors must be one of these:
[{name: Hugo de Freitas Evangelista, email: hugo.encaminhados@gmail.com}, {name: Paulo Henrique Calisto dos Santos, email: hsspaulo9@gmail.com}, {name: Hudson Junior Rodrigues Silva, email: hudson.01junior@gmail.com}, {name: Ivan Aloizio de Lana Filho, email: ivan.lana@icloud.com}]. hugo.encaminhados@gmail.com must own 80% of the code/commits.

TEACHER DESCRIPTION OF THE GOALS:
At the university platform, the teacher specified this goals as the ones he'll evaluate:

Objetivos:
- Avaliar a integração completa entre Front-End (React Native com Expo e TypeScript) e Back-End (Spring Boot com Java).
- Verificar a aplicação dos conceitos de arquitetura cliente-servidor.
- Validar a implementação de autenticação, CRUD e comunicação com API.
- Avaliar organização de código, boas práticas e separação de responsabilidades.
- Analisar aspectos de UI/UX, responsividade e experiência do usuário.
- Observar preparo da aplicação para ambiente de produção.

Metodologia:
- Apresentação prática dos projetos pelos alunos, com demonstração funcional da aplicação mobile integrada à API, seguida de arguição técnica sobre decisões arquiteturais, segurança, estrutura do código e boas práticas adotadas.

Atividades:
- Apresentação da proposta do projeto (problema e solução).
- Demonstração do fluxo completo da aplicação (login, navegação, CRUD, integração com API).
- Demonstração da API em funcionamento (endpoints protegidos, banco de dados).
- Explicação da arquitetura do projeto (Controller, Service, Repository, Hooks, Services no Front-End).
- Apresentação das decisões de UI/UX e organização de layout.
- Demonstração do build ou preparação para deploy (quando aplicável).
- Respostas a questionamentos técnicos.

Avaliação:
- Avaliação prática valendo nota final do projeto, considerando:
- Funcionamento completo da aplicação.
- Integração correta entre Front-End e Back-End.
- Implementação adequada de segurança (quando aplicável).
- Organização e qualidade do código.
- Clareza na apresentação e domínio técnico do projeto.
- Experiência do usuário e estabilidade geral da aplicação.

So you must create, also, a pptx (in PT-BR, we're in Brazil) for the presentation and another one dividing by 4 the presentation, so each group member would study it's part to present it right.

Functional Requirements for the MVP:
[RQ]: User must be able to create an account.
[RQ]: User must be able to log into it's account.
[RQ]: User must be able to delete it's account.
[RQ]: User must be able to create a new subject.
[RQ]: User must be able to update an existing subject.
[RQ]: User must be able to delete an existing subject.
[RQ]: User must be able to define if a subject is public or private.
[RQ]: User must be able to create a new card.
[RQ]: User must be able to update an existing card.
[RQ]: User must be able to delete an existing card.
[RQ]: User must be able to answer a card.
[RQ]: User must be able to skip a card.
[RQ]: User must be able to see it's progress on a personal dashboard.
[RQ]: User must be able to send a friend request.
[RQ]: User must be able to accept a friend request.
[RQ]: User must be able to deny a received friend request.
[RQ]: User must be able to unsend a friend request that was not accepted or denied yet.
[RQ]: User must be able to see the community subjects (subjects defined as public by other users).
[RQ]: User must be able to clone a community subject to it's collection, so it will still be accessible if the owner of the collection hides, updates or deletes it.
[RQ]: User must be able to re-do a card after the time interval is done.
[RQ]: Admin must be able to manage users (create, delete, update).
[RQ]: Admin must be able to manage subjects (create, delete, update).
[RQ]: Admin must be able to manage cards (create, delete, update).

Technical Requirements for the MVP:
[RQ]: JWT + Google SSO for auth.
[RQ]: Backend folder structure must follow the pattern 1.0.
[RQ]: Backend file names must follow the pattern 1.1.
[RQ]: Backend responses must be paginated.
[RQ]: Backend will not have generic getAll endpoints, it must have a /search that will receive (or not, bc it's not demanded) a payload with data to filter (creation data, for example, for cards or subjects) and use Specification to filter the response. If the payload is empty or don't exists just return all data (paginated, ofc).
[RQ]: Frontend colors are defined on pattern 2.0.
[RQ]: Frontend must use modal confirmations and toasts with balance.
[RQ]: Frontend must use nativewind to style.


PATTERNS:
[1.0] Backend folders must follow this model:
📁 Repository
📁 Controller
    |- 📁 DTO
        |- 📁 Request
        |- 📁 Response
📁 Service
📁 Model
📁 ENUM
📁 Config
📁 Mappers
📁 Specification
And other folders that you judge necessary. Follow the name convention, not the order of the folders.
[1.1] Backend file names must follow this model:
©️ UserController
©️ UserService
©️ UserRepository
©️ UserSpecification
🇪 UserRoleENUM
📝 UserRegisterRequestDTO
📝 UserRegisterResponseDTO
🗺️ UserMapper
[2.0] Color Palette:
Light theme:
colors: {
  primary: {
    DEFAULT: "#2563EB",
    hover: "#1D4ED8",
  },

  background: {
    light: "#F8FAFC",
    dark: "#0F172A",
  },

  surface: {
    light: "#FFFFFF",
    dark: "#1E293B",
  },

  text: {
    light: "#0F172A",
    dark: "#F8FAFC",
    secondaryLight: "#64748B",
    secondaryDark: "#CBD5E1",
  },

  success: "#22C55E",
  warning: "#F59E0B",
  error: "#EF4444",
}