import { DocumentMeta } from "../types";
import { documentStore } from "./store";

type DocumentMap = Record<string, DocumentMeta>;

const MAX_RECENTS = 10;

class DocumentRepository {
    private documents: DocumentMap = {};

    async init() {
        this.documents = await documentStore.get("documents") ?? {};
    }

    getAll(): DocumentMeta[] {
        return Object.values(this.documents);
    }

    getByFilePath(filePath: string): DocumentMeta | undefined {
        return this.documents[filePath];
    }

    async save() {
        await documentStore.set("documents", this.documents);
        documentStore.save();
    }

    async add(doc: DocumentMeta) {
        this.documents[doc.filePath] = doc;
        if (Object.values(this.documents).filter((doc) => !doc.starred).length > MAX_RECENTS) {
            const sorted = Object.values(this.documents).sort(
                (a, b) => b.lastOpened.getTime() - a.lastOpened.getTime()
            );
            this.documents = sorted.slice(0, MAX_RECENTS).reduce((acc, doc) => {
                acc[doc.filePath] = doc;
                return acc;
            }, {} as DocumentMap);
        }
        await this.save();
    }

    async update(doc: DocumentMeta) {
        this.documents[doc.filePath] = doc;
        await this.save();
    }

    async delete(filePath: string) {
        delete this.documents[filePath];
        await this.save();
    }
}

export const documentRepository = new DocumentRepository();